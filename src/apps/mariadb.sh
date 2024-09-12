#!/bin/bash

# ------------------------------------------------------------------------------
# Install MariaDB v10.2.
#
# https://mariadb.org/
# ------------------------------------------------------------------------------

# Set the root password on install.
debconf-set-selections <<< "mariadb-server mysql-server/root_password password ${mysql_rootpswd}"
debconf-set-selections <<< "mariadb-server mysql-server/root_password_again password ${mysql_rootpswd}"

apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
add-apt-repository 'deb https://mirrors.ukfast.co.uk/sites/mariadb/repo/10.6/ubuntu '$(lsb_release -cs)' main'
apt-get update
apt-get -y install mariadb-server

# Once the RDBMS is installed, for security change the name of the root user.
mysql -uroot -p${mysql_rootpswd} mysql -e "UPDATE user SET user='${mysql_rootname}' WHERE user='root';"
mysql -uroot -p${mysql_rootpswd} mysql -e "FLUSH PRIVILEGES;"

# Make these the default connection credentials for the adm user only.
# https://dev.mysql.com/doc/refman/8.0/en/option-files.html
read -r -d '' my_cnf << END
[mysql]
user=${mysql_rootname}
password=${mysql_rootpswd}
host=localhost

[mysqladmin]
user=${mysql_rootname}
password=${mysql_rootpswd}
host=localhost

[mysqldump]
user=${mysql_rootname}
password=${mysql_rootpswd}
host=localhost
END

sudo -u ${adm_user} echo "${my_cnf}" > /home/${adm_user}/.my.cnf

# Global configuration for `mysqld`, the MySQL server.
cat > /etc/my.cnf << END
[mysqld]

# Send all log output to files.
log_output=FILE

# **Error Log**
# The error log contains a record of critical errors that occurred during the
# server's operation, table corruption, start and stop information.
# https://mariadb.com/kb/en/error-log/
log_error=/var/log/mysql/error.log

# **Log Verbosity**
# https://mariadb.com/kb/en/error-log/
log_warnings=4

# **General Query Log**
# Logs established client connections and statements received from clients.
# https://mariadb.com/kb/en/general-query-log/
general_log
general_log_file=/var/log/mysql/all-queries.log

# **Slow Query Log**
# Logs queries that took more than long_query_time to execute.
slow_query_log
slow_query_log_file=/var/log/mysql/slow-queries.log
long_query_time=3

END

# Make the log directory.
mkdir /var/log/mysql/
chown mysql:mysql /var/log/mysql/
chmod 0770 /var/log/mysql/

# Configure the "logrotate" utility to administer MySQL's log files.
# https://linux.die.net/man/8/logrotate
# https://mariadb.com/kb/en/rotating-logs-on-unix-and-linux/
tee /etc/logrotate.d/mariadb << END
/var/log/mysql/*.log {
  missingok              # Don't fail with an error if the log files are missing
  create 660 mysql mysql # Recreate the log files after rotation with these permissions and owner
  daily                  # Rotate logs on a daily basis
  notifempty             # Don't rotate log files that are empty
  minsize 1M             # Don't rotate logs under 1MB in size
  maxsize 100M           # Don't let individual log files exceed 100MB
  rotate 10              # Don't keep more than 10 archives of each log file
  compress               # Compress archived log files
  dateext                # Prepend the date to archived log files...
  dateformat -%Y%m%d%s   # ... using this date format
}

END

# Remove other logrotate configurations to avoid conflicts.
rm /etc/logrotate.d/mysql
rm /etc/logrotate.d/mysql-server

# Restart MariaDB so the configuration changes take effect.
systemctl restart mysql

#!/bin/bash

# ------------------------------------------------------------------------------
# Configure Nginx to serve the main hosted application.
#
# This configuration is for serving static web sites and assets.
# ------------------------------------------------------------------------------

application_nginx_conf=/etc/nginx/sites-available/${application_hostname}.conf

touch ${application_nginx_conf}
tee ${application_nginx_conf} << END

server {

  # -- ROUTING -----------------------------------------------------------------

  # Nginx will choose the most suitable virtual "server" block to process a HTTP
  # request based on a combination of domain - from the "Host" field - and port.
  # http://nginx.org/en/docs/http/request_processing.html

  # The "listen" rules define the IP addresses and ports to match.
  # http://nginx.org/en/docs/http/ngx_http_core_module.html#listen
  listen 443 ssl;
  listen [::]:443 ssl;

  # The "server_name" values are tested against the "Host" header in the request
  # message. The first name becomes the primary server name.
  # http://nginx.org/en/docs/http/ngx_http_core_module.html#server_name
  server_name ${application_hostname};

  # -- DOCUMENT ROOT -----------------------------------------------------------

  # The "root" directive sets the local filesystem directory from which to serve
  # files. http://nginx.org/en/docs/http/ngx_http_core_module.html#root
  root ${application_server_root_dir};

  # -- LOGGING -----------------------------------------------------------------

  # https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
  access_log /var/log/nginx/access.log;
  error_log /var/log/nginx/error.log warn;

  # -- SSL/TLS -----------------------------------------------------------------

  ssl_certificate /etc/letsencrypt/live/${application_hostname}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${application_hostname}/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/${application_hostname}/fullchain.pem;

  # The following configuration should give an A+ grade when tested against:
  # https://www.ssllabs.com/ssltest/analyze.html?d=www.example.com

  # Improve HTTPS performance with session resumption.
  # ssl_session_cache shared:SSL:60m;
  # ssl_session_timeout 1d;
  # ssl_session_tickets off;

  # Enable server-side protection against BEAST attacks.
  # ssl_protocols TLSv1.2;
  # ssl_prefer_server_ciphers on;
  # ssl_ciphers "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384";

  # Enable OCSP stapling.
  # http://blog.mozilla.org/security/2013/07/29/ocsp-stapling-in-firefox
  # ssl_stapling on;
  # ssl_stapling_verify on;

  resolver 1.1.1.1 1.0.0.1 [2606:4700:4700::1111] [2606:4700:4700::1001] valid=300s; # Cloudflare 1.1.1.1 service.
  resolver_timeout 5s;

  # -- HEADERS -----------------------------------------------------------------

  # Enable HTTP Strict Transport Security. Cache for six months.
  # https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security
  add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";

  # X-Frame-Options.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
  add_header X-Frame-Options DENY always;

  # X-Content-Type-Options.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Content-Type-Options
  add_header X-Content-Type-Options nosniff always;

  # X-Xss_Protection.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-XSS-Protection
  add_header X-Xss-Protection "1; mode=block" always;

  # Content-Security-Policy.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
  # https://developer.mozilla.org/en/docs/Mozilla/Add-ons/WebExtensions/Content_Security_Policy
  add_header Content-Security-Policy "default-src 'none'; frame-ancestors 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self'; base-uri 'self'; form-action 'self';";

  # Referrer-Policy.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
  # add_header Referrer-Policy "no-referrer, strict-origin-when-cross-origin";

  # -- STATIC CONTENT ----------------------------------------------------------

  # Deny requests to all files starting ".ht".
  location ~ /\.ht {
    deny all;
  }

  # Send far-future (10+ years) Expires and Cache-Control headers for JavaScript
  # and images and all other static files. Simply serve updates for these assets
  # from different URLs to bust their local caches.
  location ~* \.(bmp|css|gif|ico|jpeg|jpg|js|png|svg|svgz|webp|woff|woff2)$ {
    access_log off;
    expires max;
  }

  # Cache static HTML, JSON and XML files for just 1 hour.
  location ~* \.(htm|html|json|xml)$ {
    expires 1h;
  }

  # Route all requests directly to the static assets where applicable, else
  # let the index.html file in the server root capture everything.
  location / {
    try_files \$uri \$uri/ /index.html;
  }

}

END

# Enable the server configuration.
ln -s ${application_nginx_conf} /etc/nginx/sites-enabled/

# Check for syntax errors in the Nginx config and attempt reload.
nginx -t
systemctl reload nginx

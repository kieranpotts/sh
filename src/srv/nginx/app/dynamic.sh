#!/bin/bash

# ------------------------------------------------------------------------------
# Configure Nginx to serve the main hosted application.
#
# This configuration is for serving dynamic Node.js applications.
# ------------------------------------------------------------------------------

application_nginx_conf=/etc/nginx/sites-available/${application_hostname}.conf

touch ${application_nginx_conf}
tee ${application_nginx_conf} << END

# Map HTTP response message status codes to their titles and descriptions. These
# are used as Server-Side Includes variables in custom error pages.
# https://httpstatuses.com/
map \$status \$status_title {
  400 'Bad Request';
  401 'Unauthorized';
  402 'Payment Required';
  403 'Forbidden';
  404 'Not Found';
  405 'Method Not Allowed';
  406 'Not Acceptable';
  407 'Proxy Authentication Required';
  408 'Request Timeout';
  409 'Conflict';
  410 'Gone';
  411 'Length Required';
  412 'Precondition Failed';
  413 'Payload Too Large';
  414 'URI Too Long';
  415 'Unsupported Media Type';
  416 'Range Not Satisfiable';
  417 'Expectation Failed';
  418 'I\'m a Teapot';
  421 'Misdirected Request';
  422 'Unprocessable Entity';
  423 'Locked';
  424 'Failed Dependency';
  426 'Upgrade Required';
  428 'Precondition Required';
  429 'Too Many Requests';
  431 'Request Header Fields Too Large';
  444 'Connection Closed Without Response';
  451 'Unavailable For Legal Reasons';
  500 'Internal Server Error';
  501 'Not Implemented';
  502 'Bad Gateway';
  503 'Service Unavailable';
  504 'Gateway Timeout';
  505 'HTTP Version Not Supported';
  506 'Variant Also Negotiates';
  507 'Insufficient Storage';
  508 'Loop Detected';
  510 'Not Extended';
  511 'Network Authentication Required';
  599 'Network Connect Timeout Error';
  default '';
}
map \$status \$status_description {
  400 'You sent a request that our server could not understand.';
  401 'We could not verify that you are authorized to access this resource. You may have supplied invalid credentials, such as a bad password.';
  402 'Payment is required.';
  403 'You do not have permission to access the requested directory. There may be no index document, or the directory is read-protected.';
  404 'The resource you requested could not be found, but it may become available again in the future.';
  405 'The HTTP method is not allowed for the requested URL.';
  406 'An appropriate representation of the requested resource could not be found on our server.';
  407 'Our proxy server could not verify that you are authorized to access the requested resource.';
  408 'Our server timed out waiting for a complete request from you.';
  409 'We could not complete your request because there is a conflict between the input you provided and the current state of the resource on our server.';
  410 'The requested resource is no longer available, and there is no forwarding address.';
  411 'The Content-Length header field in your request was found to be invalid or missing entirely.';
  412 'One or more of the header fields in your request was found to be invalid.';
  413 'The amount of data you provided in your request exceeded our capacity limit.';
  414 'The length of the URL you requested exceeds the capacity limit for our server.';
  415 'We are unable to serve this resource in the media format you requested.';
  416 'The range of resources you requested does not match what is currently available on our server.';
  417 'An expectation given in your request could not be met by our server.';
  418 'You attempted to brew coffee with a teapot. Seriously?';
  421 'Your request was directed at a server that is not intended to process it.';
  422 'We could not process some of the instructions contained in your request.';
  423 'The requested resource is currently locked.';
  424 'We could not process your request because the requested action depended on another action, and that other action failed.';
  426 'Our server could not handle your request, but it might be able to do so if you upgrade to a different protocol.';
  428 'This request is required to be conditional, for example you might need to use an If-Match header.';
  429 'Requests to our servers are rate limited, and you have now sent too many requests within a period of time. Please try again later.';
  431 'One or more of the header fields in your HTTP message were too large for our server to handle.';
  444 'Our server closed your connection without sending a response. Our system may have suspected your request to be malicious or malformed.';
  451 'We cannot provide access to the requested resource for legal reasons.';
  500 'Our server encountered an unexpected error and was unable to complete your request.';
  501 'We do not support the requested action.';
  502 'Our proxy server received an invalid response from one of our upstream services.';
  503 'Our service is temporarily unable, due to maintenance downtime or capacity problems. Please try again later.';
  504 'Our proxy server did not receive a timely response from one of our upstream services.';
  505 'Our server does not support the major version of the HTTP protocol that was used in your request.';
  506 'The requested resource is intended to be used for content negotiation and is in itself not a proper resource.';
  507 'We could not complete your request due to insufficient free space left in your storage allocation.';
  508 'Our server terminated because one of its processes was found to be spinning in an infinite loop.';
  510 'Our server could not return all of the information necessary for you to issue an extended request.';
  511 'You first need to authenticate to gain access to our network.';
  599 'A proxy server timed out its connection with the back-end service.';
  default '';
}

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
  # files. This is disabled for this server, since we want Nginx to handle every
  # request, including for static files.
  # http://nginx.org/en/docs/http/ngx_http_core_module.html#root

  # root ${application_server_root_dir};

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

  # -- HTTP CONFIGURATION ------------------------------------------------------

  # Disable checking of client request payload size.
  # http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size
  client_max_body_size 0;

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
  # https://content-security-policy.com/
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
  # https://developer.mozilla.org/en/docs/Mozilla/Add-ons/WebExtensions/Content_Security_Policy
  #
  # Our CSP:
  # - Disallow embedding of frames, objects or applets.
  # - Allow scripts to be loaded from same-origin or inline.
  # - Allow scripts to make requests (XHR, Fetch, WebSocket) to the same-origin only.
  # - Allow images to be loaded from same-origin or via the data scheme (eg base64 encoded)
  # - Allow styles to be loaded from same-origin or inline.
  # - The base URL must be the same-origin.
  # - Forms must be submitted to the same-origin.
  #
  add_header Content-Security-Policy "default-src 'none'; frame-ancestors 'none'; script-src 'self' 'unsafe-inline'; connect-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; base-uri 'self'; form-action 'self';";

  # Referrer-Policy.
  # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy
  add_header Referrer-Policy "no-referrer, strict-origin-when-cross-origin";

  # -- STATIC CONTENT ----------------------------------------------------------

  # DISABLED - Not required when there is no root directory for the server.
  # Deny requests to all files starting ".ht".
  # location ~ /\.ht {
  #   deny all;
  # }

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

  # -- ERROR PAGES -------------------------------------------------------------

  # Replace Nginx's default error page for all client and server errors.
  error_page 400 401 402 403 404 405 406 407 408 409 410 411 412 413 414 415 416 417 418 421 422 423 424 426 428 429 431 444 451 /error.html;
  error_page 500 501 502 503 504 505 506 507 508 510 511 599 /error.html;

  # Error pages may be loaded via internal requests only - eg via the error_page
  # directive. Support Server-Side Includes templating - so the status title and
  # code can be automatically injected into the page. The pages are installed in
  # the /var/www directory, to keep them separate from application code.
  location = /error.html {
    ssi on;
    internal;
    root /var/www;
  }

  # -- BACKEND PROXY -----------------------------------------------------------

  # For all requests:
  # 1. Try to resolve the path to a real file (this will fail if no "root" dir).
  # 2. Else forward to the Node.js back-end.
  location / {
    try_files \$uri @backend;
  }

  # Forward all other requests to Node.js.
  # The port must match what Node.js listens on internally.
  location @backend {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_cache_bypass \$http_upgrade;

  }

}

END

# Copy "error_page" files to "/var/www/err/**". This provides a means to provide
# variations on the default error page design - for example 502 may be different
# from 404. There's no need to change permissions on these files, being owned by
# root is fine for Nginx.
mkdir -p /var/www
for file in ${boot_dir}/inc/err/*; do
  file_name="$(basename "${file}")"
  cat "${file}" >> "/var/www/${file_name}"
done

# Enable the server configuration.
ln -s ${application_nginx_conf} /etc/nginx/sites-enabled/

# Check for syntax errors in the Nginx config and attempt reload.
nginx -t
systemctl reload nginx

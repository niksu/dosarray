## Preparing the targets
The precise code + configs of targets are included in `servers.tgz`.
These are the services I set up:
```
Apache (worker MPM) 192.168.0.2:8011
Apache (event MPM) 192.168.0.2:8013
Nginx 192.168.0.2:8012
lighttpd 192.168.0.2:8014
Varnish 192.168.0.2:8015
HAproxy 192.168.0.2:8016
```

## Controlling the targets
I run these commands in `/home/nsultana/`:
```
src/prefix/bin/apachectl start
src/prefix_apache_event/bin/apachectl start
src/prefix/sbin/nginx
src/prefix/sbin/lighttpd -f src/prefix/conf/lighttpd.conf
src/prefix/sbin/varnishd -a 192.168.0.2:8015 -b 192.168.0.2:8013
src/prefix/sbin/haproxy -f src/prefix/conf/haproxy.conf
```

To stop later, I run these commands:
```
src/prefix/bin/apachectl stop
src/prefix_apache_event/bin/apachectl stop
src/prefix/sbin/nginx -s stop
killall lighttpd
killall varnishd
killall haproxy
```

## Configuring the targets
These are my contents for `lighttpd.conf`:
```
server.document-root = "/home/nsultana/src/prefix/htdocs/"
index-file.names = ( "index.html" )
server.port = 8014
mimetype.assign = (
  ".html" => "text/html",
  ".txt" => "text/plain",
  ".jpg" => "image/jpeg",
  ".png" => "image/png"
)
```

These are my contents for `haproxy.conf`:
```
    global
        daemon
        maxconn 256

    defaults
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

    frontend http-in
        bind 192.168.0.2:8016
        default_backend servers

    backend servers
        server server1 192.168.0.2:8013 maxconn 32
```

My delta for `src/prefix/conf/httpd.conf`:
```
52c52,53
< Listen 80
---
> Listen 192.168.0.2:8011
```
(it's similar for `src/prefix_apache_event/conf/httpd.conf`)

And my delta for `src/prefix/conf/nginx.conf`:
```
3a4
> # NOTE by default worker_processes == 1.
13c14,16
<     worker_connections  1024;
---
> #    worker_connections  1024;
> #    worker_connections  20;
>     worker_connections  10;
36,37c39,42
<         listen       80;
<         server_name  localhost;
---
>         #listen       8012;
>         listen       192.168.0.2:8012;
>         #server_name  localhost;
>         #server_name  192.168.0.2;
```

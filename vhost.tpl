upstream VHOST.nginx_backend {
	 server IP max_fails=1 fail_timeout=60;
}

server {
	server_name VHOST;
	access_log /var/log/nginx/VHOST.access.log;
	error_log /var/log/nginx/VHOST.error.log;

	location / {
		 include /etc/nginx/VHOST.whitelist;
		 #LearningMode;
		 SecRulesEnabled;
		 #SecRulesDisabled;
		 DeniedUrl "/RequestDenied";
		 CheckRule "$SQL >= 8" BLOCK;
		 CheckRule "$RFI >= 8" BLOCK;
		 CheckRule "$TRAVERSAL >= 4" BLOCK;
		 CheckRule "$EVADE >= 4" BLOCK;
		 CheckRule "$XSS >= 8" BLOCK;
		 proxy_cache off;
		 proxy_set_header	HOST	$host;
		 proxy_pass http://VHOST.nginx_backend;
		 if ($request_method = HEAD) {
		    return 200;
        	 }
	}
	
	location ~* (\.jpg|\.jpeg|\.png|\.gif|\.ico|\.swf|\.txt|\.iso|\.avi|\.flv|\.mp4)$ {
		 gzip off;
		 #gzip_static off;
		 expires 1h;
		 proxy_cache_valid any 60m;
		 proxy_cache_use_stale updating invalid_header error timeout http_404 http_500 http_502 http_503 http_504;
		 proxy_cache_min_uses 0;
		 proxy_cache big;
		 proxy_pass http://VHOST.nginx_backend;
	}	
	
	location /index.php/1.0 {
        	 return 444;
	}

	location /RequestDenied {
		 #proxy_pass http://VHOST.nginx_backend;
		 return 444;
}

	error_page 500 502 503 504 /50x.html;
	location = /50x.html {
		 root /usr/share/nginx/www;
	}
}
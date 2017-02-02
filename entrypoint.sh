#!/bin/sh

# setup nginx
sed -i "s|FQDN|${FQDN}|g" /http
sed -i "s|FQDN|${FQDN}|g" /https

sed -i "s|HTTP|${HTTP}|g" /http
sed -i "s|HTTPS|${HTTPS}|g" /https

# download sources
setup_code () {
	if [ "$REPO" = "external" ]; then
		echo "external code mode"
	else
		if ! [ -d /code/.git ]; then
			mkdir /code
			if [ "$BRANCH" = "master" ]; then
				cd /code && git init && git remote add origin https://$GIT_USER:$GIT_PASS@$REPO
		    	cd /code && git pull origin master && git branch --set-upstream-to=origin/master master
			else
				cd /code && git init && git remote add origin https://$GIT_USER:$GIT_PASS@$REPO
		    	cd /code && git pull origin master && git branch --set-upstream-to=origin/master master
		    	cd /code && git checkout ${BRANCH}
			fi
		else
			/sync.sh
		fi
	fi
}

setup_nginx_le () {
	# make dhparams
	if [ ! -f /etc/nginx/ssl/dhparams.pem ]; then
    	echo "make dhparams"
    	cd /etc/nginx/ssl
    	openssl dhparam -out dhparams.pem 2048
    	chmod 600 dhparams.pem
	fi
	(
 		while :
 		do
 		if [ ! -f /etc/nginx/sites-enabled/https ]; then
 			if [ ! -f /etc/nginx/sites-enabled/http ]; then
	 			mv /http /etc/nginx/sites-enabled/http
	 		fi
 			nginx -s reload
 			sleep 3
 			/le.sh && mv /https /etc/nginx/sites-enabled/https
 			nginx -s reload
 			sleep 60d
 		else
 			if [ ! -f /etc/nginx/sites-enabled/http ]; then
	 				mv /http /etc/nginx/sites-enabled/http
	 		fi
 			mv /etc/nginx/sites-enabled/https /https 
			nginx -s reload
 			sleep 3
 			/le.sh && mv /https /etc/nginx/sites-enabled/https
 			nginx -s reload
 			sleep 60d
 		fi
 		done
	) &
}

	setup_code
	/sync.sh &
	setup_nginx_le

/usr/bin/supervisord

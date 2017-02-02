FROM kudato/docker-supervisor:latest

MAINTAINER Alexander Shevchenko <kudato@me.com>

ENV EMAIL mail@example.com

ENV REPO external
ENV BRANCH master
#
ENV GIT_USER nosetuser
ENV GIT_PASS nosetpass

ENV HTTP 80
ENV HTTPS 443
#
ENV FQDN example.com

# update lists
RUN apt-get update && apt-get upgrade -y
# letsencrypt
RUN apt-get install -y letsencrypt
ADD le.sh /le.sh
# nginx
RUN apt-get install -y nginx git curl nano && \
	echo "[program:nginx]" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "command = /usr/sbin/nginx" >> /etc/supervisor/conf.d/supervisord.conf && \
	echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /etc/nginx/sites-enabled/* && mkdir -p /usr/share/nginx/html
ADD nginx.conf /etc/nginx/
ADD http /http
ADD https /https

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod +x /le.sh && \
	mkdir /etc/nginx/ssl
ADD sync.sh /sync.sh
RUN chmod +x /sync.sh && apt-get clean 
###########################################################################
CMD ["/entrypoint.sh"]
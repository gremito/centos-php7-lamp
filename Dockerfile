FROM centos:6.9
MAINTAINER Takuya Iwamoto <grem.takuya0223@gmail.com>

# Settings
RUN sed -i '/^ZONE/d' /etc/sysconfig/clock
RUN sed -i '/^UTC/d' /etc/sysconfig/clock
RUN echo 'ZONE="Asia/Tokyo"' >> /etc/sysconfig/clock
RUN echo 'UTC="false"' >> /etc/sysconfig/clock
RUN cp -p /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

# yum update
RUN yum -y update
RUN yum clean all
RUN yum history sync

# install groupinstall & Settings
RUN yum -y groupinstall "Japanese Support"
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8
RUN echo 'LANG="ja_JP.UTF-8"' > /etc/sysconfig/i18n

# install epel
#RUN ls -lt /etc/yum.repos.d
#RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
#RUN ls -lt /etc/yum.repos.d

# install httpd
RUN yum -y install httpd vim-enhanced bash-completion unzip

# Add my.cnf
ADD my.cnf /etc/my.cnf

# install mysql
#RUN yum remove mysql*
RUN yum install -y http://repo.mysql.com/mysql-community-release-el6-5.noarch.rpm
RUN yum install -y mysql mysql-devel mysql-server mysql-utilities
#RUN echo "NETWORKING=yes" > /etc/sysconfig/network
ENV MYSQL_ROOT_PASSWORD 'password'
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

# start mysqld to create initial tables
#RUN service mysqld start

# install php
# PHP7.1
RUN yum remove php-*
#RUN yum install --enablerepo=remi,remi-php71 php php-devel php-mbstring php-pdo php-gd php-xml php-mcrypt
RUN yum install -y --enablerepo=remi,remi-php71 php php-devel php-mbstring php-pdo php-gd php-mysql php-pear \
    && sed -ri "s/;date.timezone =/date.timezone = Asia\/Tokyo/g" /etc/php.ini \
    && echo '<?php phpinfo();' > /var/www/html/info.php

# iinstall pip
RUN yum install -y python-pip && pip install pip --upgrade

# install sshd
RUN yum install -y openssh-server openssh-clients passwd

RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config && echo 'root:changeme' | chpasswd

WORKDIR /var/www/html
VOLUME /var/www/html
VOLUME /var/conf

# ADD httpd.conf /etc/httpd/conf/httpd.conf

# supervisor
RUN yum install -y supervisor
COPY ./supervisord.conf /etc/supervisord.conf

EXPOSE 3306 80
CMD ["/usr/bin/supervisord", "-n"]

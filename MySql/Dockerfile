# Image 
FROM debian:jessie

MAINTAINER Domos <domos.vesta@gmail.com>

ARG ROOTPWD='azer1234'
ENV MYSQLROOTPWD='azer1234'

# Paramètres apt
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
RUN echo "deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free"             > /etc/apt/sources.list \
&& echo "deb http://security.debian.org/ jessie/updates main contrib non-free"          >> /etc/apt/sources.list \
&& echo "deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free"     >> /etc/apt/sources.list \
&& echo "deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free"   >> /etc/apt/sources.list

# Update, upgrade et installation des utilités courantes, vous pouvez en enlever ou en rajouter
RUN apt-get update && apt-get upgrade -y && apt-get -y dist-upgrade && apt-get install -y \
net-tools \
locales \
vim \
mysql-client \
mysql-server

RUN apt-get clean

# Locales
RUN sed -i "s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g" /etc/locale.gen
RUN locale-gen && dpkg-reconfigure locales && /usr/sbin/update-locale LC_ALL=fr_FR.UTF-8 LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

# Timezone
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# root
RUN echo "root:${ROOTPWD}" | chpasswd
# For some personal configuration
#ADD root/.bashrc root/.bash_aliases root/.vimrc  /root/

# MySql
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" /etc/mysql/my.cnf

VOLUME /var/lib/mysql
WORKDIR /root

# Exposer le port MySql
EXPOSE 3306

ADD ./mysqlstartup.sh /opt/mysqlstartup.sh
# CMD command must be in 'exec form' (list) otherwise 'trap' command in script will not receive SIGTERM signal !
CMD ["/opt/mysqlstartup.sh"]

# -----------------------------------------------------------------------------

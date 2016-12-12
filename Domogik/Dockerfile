# Image 
FROM debian:jessie

MAINTAINER Domos <domos.vesta@gmail.com>

# Unlike an ARG instruction, ENV values are always persisted in the built image.
ENV DOMOGIK_RELEASE=develop
ENV DOMOGIKMQ_RELEASE=develop
ENV DOMOWEB_RELEASE=develop
ENV PLUGINS_RELEASE=develop
ENV USERNAME=domogik
ENV USERUID=1000
ENV USERGID=1000
ENV MYSQLROOTPWD='azer1234'
ENV MYSQLUSERPWD='azer1234'
ENV MYSQLHOST=mysqldb
ENV DOMOGIKID=mydockerdomogik

# ARG variable can be change at build-time to the builder with the docker build command using the --build-arg USERNAME=<value> flag.
ARG ROOTPWD='azer1234'
ARG USERPWD='azer1234'

### Paramètres apt
ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
RUN echo "deb http://ftp.fr.debian.org/debian/ jessie main contrib non-free"             > /etc/apt/sources.list \
&& echo "deb http://security.debian.org/ jessie/updates main contrib non-free"          >> /etc/apt/sources.list \
&& echo "deb http://ftp.fr.debian.org/debian/ jessie-updates main contrib non-free"     >> /etc/apt/sources.list \
&& echo "deb http://ftp.fr.debian.org/debian/ jessie-backports main contrib non-free"   >> /etc/apt/sources.list

### Update, upgrade et installation des utilités courantes, vous pouvez en enlever ou en rajouter
RUN apt-get update && apt-get upgrade -y && apt-get -y dist-upgrade && apt-get install -y \
apt-utils \
net-tools \
psmisc \
sudo \
less \
curl \
vim \
wget \
debconf-utils \
bzip2 \
dialog \
locales \
build-essential \
openssh-server \
libjpeg-dev \
zlib1g-dev \
rsync \
curl \
python2.7-dev \
python-tz \
python-pip \
libpq-dev \
git \
mysql-client


### Locales
RUN sed -i "s/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/g" /etc/locale.gen
RUN locale-gen && dpkg-reconfigure locales && /usr/sbin/update-locale LC_ALL=fr_FR.UTF-8 LANG=fr_FR.UTF-8
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR.UTF-8
ENV LC_ALL fr_FR.UTF-8

### Timezone
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

### sshd
RUN mkdir -p -m 0755 /var/run/sshd
RUN sed -i "s/PermitRootLogin without-password/PermitRootLogin yes/g" /etc/ssh/sshd_config

### root
RUN echo "root:${ROOTPWD}" | chpasswd
# For some personal configuration
##ADD root/.bashrc root/.bash_aliases root/.vimrc  /root/

### User
RUN groupadd -r ${USERNAME} --gid=${USERGID}  &&  useradd -m -g ${USERNAME} --uid=${USERUID} -s /bin/bash ${USERNAME}
RUN echo "${USERNAME}:${USERPWD}" | chpasswd
RUN adduser ${USERNAME} root && adduser ${USERNAME} staff && adduser ${USERNAME} sudo && adduser ${USERNAME} plugdev
# For some personal configuration
##ADD user/ /home/${USERNAME}/
##RUN chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}
 
### Copy Domogik
RUN mkdir -p /opt/dmg /opt/dmg/plugins \
 && chown ${USERNAME}.${USERNAME} /opt/dmg

RUN cd /opt/dmg \
 && git clone https://github.com/domogik/domogik-mq.git \
 && cd /opt/dmg/domogik-mq \
 && git checkout ${DOMOGIKMQ_RELEASE}

RUN cd /opt/dmg \
 && git clone https://github.com/domogik/domogik.git \
 && cd /opt/dmg/domogik \
 && git checkout ${DOMOGIK_RELEASE}  

RUN cd /opt/dmg \
 && git clone https://github.com/domogik/domoweb.git \
 && cd /opt/dmg/domoweb \
 && git checkout ${DOMOWEB_RELEASE}  

RUN pip install netifaces \
 && pip install sphinx-better-theme \
 && pip install Flask-Themes2 \
 && pip install alembic \
 && pip install SQLAlchemy-Utils
 
 
### Copy a few packages (Plugins are copy in a directory, after using link in /var/lib/domogik/domogik_packages to enable/disable plugins for tests)
RUN cd /opt/dmg/plugins && \
    git clone https://github.com/fritz-smh/domogik-plugin-weather.git plugin_weather && \
    cd plugin_weather && \
    git checkout ${PLUGINS_RELEASE}

RUN cd /opt/dmg/plugins && \
    git clone https://github.com/fritz-smh/domogik-plugin-diskfree.git plugin_diskfree && \
    cd plugin_diskfree && \
    git checkout ${PLUGINS_RELEASE}

RUN cd /opt/dmg/plugins && \
    git clone https://github.com/fritz-smh/domogik-plugin-ping.git plugin_ping && \
    cd plugin_ping && \
    git checkout ${PLUGINS_RELEASE}

#RUN cd /opt/dmg/plugins && \
#    git clone https://github.com/fritz-smh/domogik-plugin-rfxcom.git plugin_rfxcom && \
#    cd plugin_rfxcom && \
#    git checkout ${PLUGINS_RELEASE}


### Install a other packages    
RUN cd /opt/dmg/plugins && \
    git clone https://github.com/vdomos/domogik-plugin-vdevice.git plugin_vdevice && \
    cd plugin_vdevice && \
    git checkout ${PLUGINS_RELEASE}

RUN cd /opt/dmg/plugins && \
    git clone https://github.com/vdomos/domogik-plugin-script.git plugin_script && \
    cd plugin_script && \
    git checkout ${PLUGINS_RELEASE}

RUN cd /opt/dmg/plugins && \
    git clone https://github.com/vdomos/domogik-plugin-mqtt.git plugin_mqtt && \
    cd plugin_mqtt && \
    git checkout ${PLUGINS_RELEASE}
RUN pip install paho-mqtt

#RUN cd /opt/dmg/plugins && \
#    git clone https://github.com/vdomos/domogik-plugin-rainhour.git plugin_rainhour && \
#    cd plugin_rainhour && \
#    git checkout ${PLUGINS_RELEASE}

#RUN cd /opt/dmg/plugins && \
#    git clone https://github.com/vdomos/domogik-plugin-vigilance.git plugin_vigilance && \
#    cd plugin_vigilance && \
#    git checkout ${PLUGINS_RELEASE}

#RUN cd /opt/dmg/plugins && \
#    git clone https://github.com/vdomos/domogik-plugin-onewired.git plugin_onewired && \
#    cd plugin_onewired && \
#    git checkout ${PLUGINS_RELEASE}

#RUN cd /opt/dmg/plugins && \
#    git clone https://github.com/vdomos/domogik-plugin-rfxbnz.git plugin_rfxbnz && \
#    cd plugin_rfxbnz && \
#    git checkout ${PLUGINS_RELEASE}

RUN chown -R ${USERNAME}.${USERNAME} /opt/dmg 


### Cleanup
RUN apt-get clean

WORKDIR /root

### Volumes
#VOLUME ["/opt/dmg/", "/var/log/domogik/", "/var/lib/domogik/", "/var/lib/domoweb/"]

### Exposer le port ssh et le port de l'interface web de supervisor
EXPOSE 22 40406 40404

### Commande au démarrage des containers
ADD ./dmgstartup.sh /opt/dmg/dmgstartup.sh
# CMD command must be in 'exec form' (list) otherwise 'trap' command in script will not receive SIGTERM signal !
CMD ["/opt/dmg/dmgstartup.sh"]

# -----------------------------------------------------------------------------

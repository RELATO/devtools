FROM ubuntu:xenial
MAINTAINER Relato <consultoria@relato.com.br>

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install tools and other things
RUN DEBIAN_FRONTEND=noninteractive \
  apt-get update && \
  apt-get install -y apt-utils wget unzip tar sudo vim-nox \
          git build-essential curl wget software-properties-common \
	  libxext-dev libxrender-dev libxtst-dev python-software-properties locales \
  && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && add-apt-repository -y ppa:webupd8team/java  \
  && apt-get update \
  && apt-get install -y oracle-java8-installer 

ENV TOMCAT_VERSION 7.0.78

# Set locales
RUN locale-gen pt_BR.UTF-8
RUN locale-gen pt_BR
ENV LANG pt_BR.ISO-8859-1
ENV LANGUAGE pt_BR:pt:en
ENV LC_CTYPE pt_BR.ISO-8859-1

COPY /opt/ideaIU-2017.1.4.tar.gz /tmp/
RUN mkdir /opt/intellij \
  && tar -xzf /tmp/ideaIU-2017.1.4.tar.gz -C /opt/intellij --strip-components=1 


# Get Tomcat http://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.78/bin/apache-tomcat-7.0.78.tar.gz
RUN wget --quiet --no-cookies http://www-us.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
  tar xzvf /tmp/tomcat.tgz -C /opt && \
  mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
  rm /tmp/tomcat.tgz && \
  rm -rf /opt/tomcat/webapps/examples && \
  rm -rf /opt/tomcat/webapps/docs && \
  rm -rf /opt/tomcat/webapps/ROOT

RUN wget --quiet --no-cookies http://www-us.apache.org/dist/ant/binaries/apache-ant-1.9.9-bin.tar.gz \
  -O /tmp/ant.tgz && \
  tar xzvf /tmp/ant.tgz -C /opt && \
  mv /opt/apache-ant-1.9.9 /opt/ant && \
  rm /tmp/ant.tgz && \
  wget --quiet --no-cookies http://www-us.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
  -O /tmp/maven.tgz && \
  tar xzvf /tmp/maven.tgz -C /opt && \
  mv /opt/apache-maven-3.3.9 /opt/maven && \
  rm /tmp/maven.tgz 

ADD locale /etc/default/locale
ADD javatomcat.sh /etc/profile.d/javatomcat.sh
ADD tomcat-users.xml /opt/tomcat/conf/
ADD /opt/tomcat/conf/web.xml /opt/tomcat/conf/web.xml
ADD /opt/tomcat/bin/startup.sh /opt/tomcat/bin/startup.sh
ADD catalina.sh /opt/tomcat/bin/catalina.sh

ADD /opt/fop-server /opt/fop-server
ADD /opt/jrockit-jdk1.6.0_37 /opt/jrockit-jdk1.6.0_37

# Define commonly used JAVA_HOME variable
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN ln -s /usr/lib/jvm/java-8-oracle /opt/java && chmod 755 /etc/profile.d/javatomcat.sh
ENV JAVA_HOME /opt/java
ENV ANT_HOME /opt/ant
ENV M2_HOME /opt/maven
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin:$JAVA_HOME/bin:$ANT_HOME/bin:$M2_HOME/bin

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -  \
  && sudo apt-get install nodejs  \
  && npm install -g @angular/cli@1.1.3  \
  && npm install -g yarn  \
  && ng set --global packageManager=yarn  \
  && yarn global add yo grunt-cli gulp-cli  \
  && npm install -g npm  \
  && npm install -g node-gyp \
  && npm cache clear\
  && node-gyp configure || echo "" \
  && npm install -g generator-jhipster

# vscode dependencies
RUN DEBIAN_FRONTEND=noninteractive \ 
  apt-get -y --no-install-recommends install libc6-dev libgtk2.0-0 libgtk-3-0 libpango-1.0-0 libcairo2 libfontconfig1 libgconf2-4 libnss3 libasound2 libxtst6 unzip libglib2.0-bin libcanberra-gtk-module libgl1-mesa-glx curl build-essential gettext libstdc++6 software-properties-common  xterm automake libtool autogen libnotify-bin aspell aspell-en htop emacs gvfs-bin libxss1 rxvt-unicode-256color x11-xserver-utils libxkbfile1

# install vscode
RUN wget -O vscode-amd64.deb  https://go.microsoft.com/fwlink/?LinkID=760868 \
  && dpkg -i vscode-amd64.deb \
  && rm vscode-amd64.deb

# install flat plat theme
run wget 'https://github.com/nana-4/Flat-Plat/releases/download/3.20.20160404/Flat-Plat-3.20.20160404.tar.gz'
run tar -xf Flat-Plat*
run mv Flat-Plat /usr/share/themes
run rm Flat-Plat*gz
run mv /usr/share/themes/Default /usr/share/themes/Default.bak
run ln -s /usr/share/themes/Flat-Plat /usr/share/themes/Default

# install hack font
run wget 'https://github.com/chrissimpkins/Hack/releases/download/v2.020/Hack-v2_020-ttf.zip'
run unzip Hack*.zip
run mkdir /usr/share/fonts/truetype/Hack
run mv Hack* /usr/share/fonts/truetype/Hack
run fc-cache -f -v

# create our developer user
workdir /root
copy /developer /developer
RUN groupadd -r developer -g 1111 \
  && useradd -u 1111 -r -g developer -d /developer -s /bin/bash -c "Software Developer" developer \
  && chmod +x /developer/bin/* \
  && chown -R developer:developer /developer \
  && echo "developer ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/developer
workdir /developer


EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"

# Cleaning the house
RUN  apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && rm -rf /var/cache/oracle-jdk8-installer

# set environment variables
env PATH /developer/.npm/bin:$PATH
env NODE_PATH /developer/.npm/lib/node_modules:$NODE_PATH
env BROWSER /developer/.local/share/firefox/firefox-bin

# mount points
volume ["/developer/.config/Code"]
volume ["/developer/.vscode"]
volume ["/developer/.ssh"]
volume ["/developer/projects"]

USER developer
WORKDIR /developer

# install firefox
run mkdir Applications 
run wget "https://download.mozilla.org/?product=firefox-aurora-latest-ssl&os=linux64&lang=en-US" -O firefox.tar.bz2 
run tar -xf firefox.tar.bz2 
run  mv firefox .local/share 
run rm firefox.tar.bz2

# links for firefox
run ln -s /developer/.local/share/firefox/firefox /developer/bin/x-www-browser \
  && ln -s /developer/.local/share/firefox/firefox /developer/bin/gnome-www-browser
# default browser firefox
run sudo ln -s /developer/.local/share/firefox/firefox /bin/xdg-open

# Launch Tomcat
#CMD ["/opt/tomcat/bin/catalina.sh", "run"]
#CMD ["/opt/intellij/bin/idea.sh"]
# start vscode
#entrypoint ["/developer/bin/start-shell"]
CMD ["/bin/sh"]

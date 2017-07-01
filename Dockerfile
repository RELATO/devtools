FROM ubuntu:16.04

MAINTAINER Relato <consultoria@relato.com.br>

ENV TOMCAT_VERSION 7.0.78

# Set locales
RUN locale-gen pt_BR.UTF-8
RUN locale-gen pt_BR
ENV LANG pt_BR.ISO-8859-1
ENV LANGUAGE pt_BR:pt:en
ENV LC_CTYPE pt_BR.ISO-8859-1

# Fix sh
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install dependencies
RUN apt-get update && \
         apt-get install -y git build-essential curl wget software-properties-common \
	libxext-dev libxrender-dev libxtst-dev \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

# Install JDK 8
RUN \
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
add-apt-repository -y ppa:webupd8team/java && \
apt-get update && \
apt-get install -y oracle-java8-installer wget unzip tar && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /var/cache/oracle-jdk8-installer


# Get Tomcat http://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.78/bin/apache-tomcat-7.0.78.tar.gz
RUN wget --quiet --no-cookies http://www-us.apache.org/dist/tomcat/tomcat-7/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tgz && \
tar xzvf /tmp/tomcat.tgz -C /opt && \
mv /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
rm /tmp/tomcat.tgz && \
rm -rf /opt/tomcat/webapps/examples && \
rm -rf /opt/tomcat/webapps/docs && \
rm -rf /opt/tomcat/webapps/ROOT

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
RUN ln -s /usr/lib/jvm/java-8-oracle /opt/java
ENV JAVA_HOME /opt/java
ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin:$JAVA_HOME/bin

EXPOSE 8080
EXPOSE 8009
VOLUME "/opt/tomcat/webapps"

# Launch Tomcat
#CMD ["/opt/tomcat/bin/catalina.sh", "run"]

COPY /opt/ideaIU-2017.1.4.tar.gz /tmp/
RUN mkdir /opt/intellij \
 && tar -xzf /tmp/ideaIU-2017.1.4.tar.gz -C /opt/intellij --strip-components=1 \
 && rm -rf /tmp/*

RUN mkdir /data
VOLUME "/data"
WORKDIR /data

#CMD ["/opt/intellij/bin/idea.sh"]
CMD ["/bin/sh"]

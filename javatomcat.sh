alias tstartup="/opt/tomcat/bin/startup.sh"
alias tshutdown="/opt/tomcat/bin/shutdown.sh"
alias tl="tail -f /opt/tomcat/logs/catalina.out"
alias torestart="/opt/tomcat/bin/shutdown.sh;killall -9 java;killall -9 java;rm -rf /opt/tomcat/work/Catalina/;/opt/tomcat/bin/startup.sh;tl"

JAVA_HOME=/opt/java
TOMCAT_HOME=/opt/tomcat
M2_HOME=/opt/maven
ANT_HOME=/usr/share/ant

export TOMCAT_HOME
export JAVA_HOME
export ANT_HOME
export M2_HOME

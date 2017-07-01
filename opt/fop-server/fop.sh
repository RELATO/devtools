#!/bin/sh
cd /opt/fop-server/
nohup java -Djava.ext.dirs=lib -classpath bin -Xms64m -Xmx128m -server br.com.relato.fop.server.Main &

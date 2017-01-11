FROM ubuntu:12.04

# Step-1 : Install dependencies
RUN apt-get update -y

# Step-2(a) : Install Oracle Java 8
ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
    apt-get clean && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

# Step-2(b) : Set Oracle Java as the default Java
RUN update-java-alternatives -s java-8-oracle
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

# Step-3(a) : Install Tomcat
ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.23
ENV CATALINA_HOME /usr/lib/tomcat
RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
	
RUN mkdir -p /usr/lib/tomcat \
  && wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
	wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
	tar zxf apache-tomcat-*.tar.gz && \
 	rm apache-tomcat-*.tar.gz && \
 	mv apache-tomcat* tomcat
	
# Step-3(b) : Create Tomcat admin user	
ADD create_tomcat_admin_user.sh /create_tomcat_admin_user.sh
RUN mkdir /etc/service/tomcat
ADD run.sh /etc/service/tomcat/run
RUN chmod +x /*.sh
RUN chmod +x /etc/service/tomcat/run

# Step-4 : Deploy the war in tomcat
RUN rm -rf ${CATALINA_HOME}/webapps/*
RUN cp /usr/local/DeployTomcat/test.html /usr/local/tomcat/apache-tomcat-${TOMCAT_MINOR_VERSION}/webapps/

EXPOSE 8080

CMD ["catalina.sh", "run"]

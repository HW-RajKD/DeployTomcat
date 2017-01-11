FROM ubuntu:12.04
MAINTAINER RAJ KUMAR DUBEY (rajkumar.dubey@heavywater.solutions)

# Step-1(a) : Install dependencies
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update -y

# Step-1(b) : Install python-software-properties - This enables add-apt-repository for use later in the process.
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common

# Step-2(a) : Install Oracle Java 8
ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
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
	
RUN mkdir -p ${CATALINA_HOME} \
  && wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
	wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
	tar zxf apache-tomcat-*.tar.gz && \
 	rm apache-tomcat-*.tar.gz && \
 	mv apache-tomcat* ${CATALINA_HOME}
	
# Step-3(b) : Create Tomcat admin user	
ADD create_tomcat_admin_user.sh ${CATALINA_HOME}/create_tomcat_admin_user.sh
ADD run.sh ${CATALINA_HOME}/run
RUN chmod +x ${CATALINA_HOME}/*.sh
RUN chmod +x ${CATALINA_HOME}/run

# Step-4 : Deploy the war in tomcat
RUN rm -rf ${CATALINA_HOME}/webapps/*
RUN sudo ls /home/ec2-user/
RUN cp test.html ${CATALINA_HOME}/apache-tomcat-${TOMCAT_MINOR_VERSION}/webapps/

EXPOSE 8080

CMD ["catalina.sh", "run"]

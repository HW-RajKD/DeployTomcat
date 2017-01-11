FROM ubuntu:12.04

# Install dependencies
RUN apt-get update -y

# Install app
RUN rm -rf /var/www/*
ADD src /var/www

# Install Java
RUN apt-get install -y default-jdk

# Install tomcat
RUN apt-get install -y tomcat7

RUN /opt/tomcat/bin/startup.sh

EXPOSE 80

CMD ["catalina.sh", "run"]

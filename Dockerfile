FROM tomcat:8.0
MAINTAINER "RAJ KUMAR DUBEY <rajkumar.dubey@heavywater.solutions>

# Step-2 : Install Git
RUN apt-get update && apt-get install -y git

# Step-3 : Install Maven
ENV MAVEN_VERSION 3.3.9	

RUN mkdir -p /usr/share/maven \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar -xzC /usr/share/maven --strip-components=1 \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
VOLUME /root/.m2
CMD ["mvn"] 

# Step-4 : Get the project from github
RUN cd /usr/local && git clone https://github.com/HW-RajKD/HeavyWater-TesseractWebservice.git

# Step-5 : Build the project
RUN cd /usr/local/HeavyWater-TesseractWebservice && /usr/local/maven/bin/mvn -Dmaven.test.skip=true package

# Step-6 : Deploy the war in tomcat
RUN rm -rf ${CATALINA_HOME}/apache-tomcat-${TOMCAT_VERSION}/webapps/*
RUN cp /usr/local/HeavyWater-TesseractWebservice/target/Hocr-1.0.war ${CATALINA_HOME}/apache-tomcat-${TOMCAT_VERSION}/webapps/

CMD service tomcat start && tail -f /var/lib/tomcat/logs/catalina.out

# Forward HTTP ports
EXPOSE 8080
CMD ["catalina.sh", "run"]

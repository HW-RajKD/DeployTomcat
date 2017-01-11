FROM tomcat:8.0
FROM oracle-java8
MAINTAINER "RAJ KUMAR DUBEY (rajkumar.dubey@heavywater.solutions)

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

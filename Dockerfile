FROM mcr.microsoft.com/openjdk/jdk:21-ubuntu
VOLUME /tmp
ARG JAVA_OPTS
ENV JAVA_OPTS=$JAVA_OPTS
COPY target/helloworld-1.0.0.jar helloworld.jar
EXPOSE 8000
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar helloworld.jar --server.port=8000"]
# For Spring-Boot project, use the entrypoint below to reduce Tomcat startup time.
#ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar helloworld.jar"]

# this is multi stage 
FROM openjdk:11 as base
RUN curl -fsSLO https://get.docker.com/builds/Linux/x86_64/docker-20.10.23-ce.tgz \
  && tar xzvf docker-20.10.23.tgz \
  && mv docker/docker /usr/local/bin \
  && rm -r docker docker-20.10.23-ce.tgz 
WORKDIR /app
COPY . . 
RUN chmod +x gradlew
RUN ./gradlew build 

FROM tomcat:9
WORKDIR webapps
COPY --from=base /app/build/libs/sampleWeb-0.0.1-SNAPSHOT.war .
RUN rm -rf ROOT && mv sampleWeb-0.0.1-SNAPSHOT.war ROOT.war

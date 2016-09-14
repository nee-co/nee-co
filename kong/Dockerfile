FROM kong:0.9.0
MAINTAINER Nee-co
ARG REVISION
LABEL revision=$REVISION
COPY nginx.conf /usr/local/kong/nginx.conf
CMD ["kong", "start", "--nginx-conf", "/usr/local/kong/nginx.conf"]

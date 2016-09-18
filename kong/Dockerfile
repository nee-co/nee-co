FROM kong:0.9.1
COPY nginx.conf /usr/local/kong/nginx.conf
CMD ["kong", "start", "--nginx-conf", "/usr/local/kong/nginx.conf"]
ARG REVISION
LABEL revision=$REVISION maintainer="Nee-co"

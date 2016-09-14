FROM kong:0.9.0
ARG REVISION
LABEL revision=$REVISION maintainer="Nee-co"
COPY nginx.conf /usr/local/kong/nginx.conf
CMD ["kong", "start", "--nginx-conf", "/usr/local/kong/nginx.conf"]

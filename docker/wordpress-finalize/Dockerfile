FROM alpine:latest
RUN apk add curl
COPY ./finalize-install.sh .
ENTRYPOINT ["./finalize-install.sh"]
FROM ubuntu:latest
RUN mkdir -p /usr/local/frp
WORKDIR /usr/local/frp
COPY ./install.sh .
RUN apt-get update && apt-get install wget git -y
RUN ./install.sh && chmod +x frpc
COPY ./frpc.ini .

ENTRYPOINT ["./frpc", "-c", "./frpc.ini"]
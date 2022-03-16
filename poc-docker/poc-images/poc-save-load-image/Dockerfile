FROM alpine:3.15

LABEL version="1.0" maintainer="<kalpeva@gmail.com>"

# install java
RUN apk update && \
    apk upgrade && \
    apk add openjdk11

ENTRYPOINT ["java"]
CMD ["--version"]

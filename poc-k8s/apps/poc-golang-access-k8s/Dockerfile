# golang alpine 1.13.5-alpine
FROM golang:1.16.2-alpine AS builder

# Create appuser.
RUN adduser -D -g '' elf

# Create workspace
WORKDIR /opt/app/
COPY src/go.mod ./

# fetch dependancies
RUN go mod download
RUN go mod verify

# copy the source code as the last step
COPY src/ .

# build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/app .

# build a small image
FROM alpine:3.13.2
LABEL language="golang"

# import the user and group files from the builder.
COPY --from=builder /etc/passwd /etc/passwd

# copy the static executable
COPY --from=builder /go/bin/app /usr/local/bin/app

# use an unprivileged user.
USER elf

# run app
ENTRYPOINT ["app"]

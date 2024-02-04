#
# Build go project
#
FROM golang:1.20-alpine as go-builder

WORKDIR /app

# download the required Go dependencies
COPY go.mod ./
# COPY go.sum ./
RUN go mod download

# Copy main.go
COPY ./main.go ./main.go

# Copy scripts
COPY ./trigger_scripts ./trigger_scripts

RUN go build -o app


# Runtime container

FROM alpine:latest  

RUN apk add --no-cache bash  curl
 
RUN mkdir -p /app && \
    addgroup -S app && adduser -S app -G app && \
    chown app:app /app

WORKDIR /app

COPY --from=go-builder /app .

USER app

CMD ["./app", "localhost:2045"]  

# Base image dengan Go 1.22.3 di Alpine
FROM golang:1.22.3-alpine AS build

LABEL maintainer="froyo75@users.noreply.github.com"

# Argumen dan variabel lingkungan
ARG GITHUB_USER="derainbow"
ARG EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/evilginx2"
ENV PROJECT_DIR="/go/src/${EVILGINX_REPOSITORY}"
ENV EVILGINX_BIN="/bin/evilginx"

# Install dependencies
RUN apk add --no-cache git make bash nano

# Clone repository
RUN git clone https://${EVILGINX_REPOSITORY} ${PROJECT_DIR}

# Build aplikasi Evilginx2
WORKDIR ${PROJECT_DIR}
RUN go build -o ${EVILGINX_BIN}

# Tahap 2 - Runtime Container
FROM alpine:latest

LABEL maintainer="froyo75@users.noreply.github.com"

ENV EVILGINX_PORTS="443 80 53/udp"
ENV EVILGINX_BIN="/bin/evilginx"

# Install bash untuk runtime
RUN apk add --no-cache bash

# Salin binary dan phishlets dari tahap build
COPY --from=build ${EVILGINX_BIN} ${EVILGINX_BIN}
COPY --from=build /go/src/${EVILGINX_REPOSITORY}/phishlets /app/phishlets

# Konfigurasi runtime container
WORKDIR /app
EXPOSE ${EVILGINX_PORTS}
CMD ["/bin/evilginx", "-p", "/app/phishlets"]

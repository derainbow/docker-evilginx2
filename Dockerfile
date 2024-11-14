# Konfigurasi default untuk path dan repository
ARG EVILGINX_BIN="/bin/evilginx"
ARG GOLANG_VERSION=1.16
ARG GOPATH=/opt/go
ARG GITHUB_USER="derainbow"
ARG EVILGINX_REPOSITORY="github.com/${GITHUB_USER}/evilginx2"
ARG INSTALL_PACKAGES="go git bash nano"
ARG PROJECT_DIR="${GOPATH}/src/${EVILGINX_REPOSITORY}"

# Stage 1 - Build EvilGinx2 app
FROM alpine:latest AS build

LABEL maintainer="froyo75@users.noreply.github.com"

# Memasukkan semua argumen sekali lagi agar bisa digunakan di tahap build
ARG GOLANG_VERSION
ARG GOPATH
ARG GITHUB_USER
ARG EVILGINX_REPOSITORY
ARG INSTALL_PACKAGES
ARG PROJECT_DIR
ARG EVILGINX_BIN

# Install dependencies dan clone repository
RUN apk add --no-cache ${INSTALL_PACKAGES} \
    && wget https://dl.google.com/go/go${GOLANG_VERSION}.src.tar.gz \
    && tar -C /usr/local -xzf go${GOLANG_VERSION}.src.tar.gz \
    && rm go${GOLANG_VERSION}.src.tar.gz \
    && cd /usr/local/go/src && ./make.bash \
    && mkdir -pv ${GOPATH}/src/github.com/${GITHUB_USER} \
    && git -C ${GOPATH}/src/github.com/${GITHUB_USER} clone -b cerberus --single-branch https://${EVILGINX_REPOSITORY}.git

# Build aplikasi
WORKDIR ${PROJECT_DIR}
RUN go get -v && go build -v \
    && cp -v evilginx2 ${EVILGINX_BIN} \
    && mkdir -v /app && cp -vr phishlets /app

# Stage 2 - Build Runtime Container
FROM alpine:latest

LABEL maintainer="froyo75@users.noreply.github.com"

# Menggunakan environment untuk runtime container
ENV EVILGINX_PORTS="443 80 53/udp"
ARG EVILGINX_BIN

RUN apk add --no-cache bash && mkdir -v /app

# Install EvilGinx2 dari tahap build
WORKDIR /app
COPY --from=build ${EVILGINX_BIN} ${EVILGINX_BIN}
COPY --from=build /app .

# Konfigurasi runtime container
EXPOSE ${EVILGINX_PORTS}
CMD ["/bin/evilginx", "-p", "/app/phishlets"]

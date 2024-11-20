FROM alpine:latest AS build
ARG PROJECT_DIR="/opt/go/src/evil/evilginx2"

#put your repo here
ARG REPO_URL=""

# Set environment variables
ENV GOLANG_VERSION=1.22.3
ENV PATH="/usr/local/go/bin:${PATH}"

# Install dependencies
RUN apk add --no-cache wget tar bash git make nano \
    && wget https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz \
    && rm go${GOLANG_VERSION}.linux-amd64.tar.gz

# Verify Go installation
RUN go version \
    && mkdir -pv /opt/go/src/evil \
    && git -C /opt/go/src/evil clone ${REPO_URL}

###section untuk modifikasi kode evilginx sebelum di compile####

###end section ################


# Build EvilGinx2
WORKDIR ${PROJECT_DIR}
RUN set -x \
    && go get -v \
    && go build -v \
    && make \
    && mkdir -v /app \
    && cp -vr phishlets /app \
    && cp -vr redirectors /app \
    && cp -v build/evilginx /bin/evilginx


# Stage 2 - Build Runtime Container
FROM alpine:latest
ENV EVILGINX_PORTS="443 80 53/udp"
ARG EVILGINX_BIN="/bin/evilginx"


RUN apk add --no-cache bash nano && mkdir -v /app
# Install EvilGinx2
WORKDIR /app
COPY --from=build ${EVILGINX_BIN} .
COPY --from=build /app .
# Salin file blacklist.txt ke /root/.evilginx di dalam container
RUN wget -O /root/.evilginx/blacklist.txt https://github.com/aalex954/MSFT-IP-Tracker/releases/latest/download/msft_asn_ip_ranges.txt

EXPOSE ${EVILGINX_PORTS}

CMD ["/app/evilginx", "-p", "/app/phishlets","-t","/app/redirectors", "-debug"]

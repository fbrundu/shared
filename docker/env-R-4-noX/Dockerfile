############################################################
# Dockerfile for R (version 4)
############################################################

FROM ubuntu:20.04
LABEL author=fbrundu

# Set to R4 version during build. E.g. 4.0.3
ENV R4_VERSION="4.0.3"

############################################################

## Silence interactive warnings for container build
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    build-essential \
    gcc \
    gfortran \
    libbz2-dev \
    libcurl3-dev \
    liblzma-dev \
    libpcre2-dev \
    libreadline-dev \
    make \
    wget \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

############################################################

WORKDIR /home/ubuntu/

RUN wget https://cran.rstudio.com/src/base/R-4/R-${R4_VERSION}.tar.gz
RUN tar -xvf R-${R4_VERSION}.tar.gz
RUN rm R-${R4_VERSION}.tar.gz
RUN mv /home/ubuntu/R-${R4_VERSION}/ /home/ubuntu/R-build/
WORKDIR /home/ubuntu/R-build/
RUN ./configure --with-x=no
RUN make
RUN make && make install

ENTRYPOINT [ "bash" ]

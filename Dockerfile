FROM debian AS build

ARG kea_version=2.0.2

RUN apt-get update && apt-get install -y \
    wget \
    tar \
    build-essential \
    automake \
    libtool \
    pkg-config \
    build-essential \
    ccache \
    libboost-dev \
    libboost-system-dev \
    liblog4cplus-dev \
    libssl-dev

WORKDIR /

RUN wget https://downloads.isc.org/isc/kea/${kea_version}/kea-${kea_version}.tar.gz && \
    tar -xvf kea-${kea_version}.tar.gz

WORKDIR /kea-${kea_version}

RUN make -p /usr/local/kea-dhcp && \
    autoreconf --install ; \
    bash ./configure --prefix=/usr/local/kea-dhcp && \
    make && \
    make install && \
    ldconfig

FROM debian

RUN apt-get update && apt-get -y install \
    liblog4cplus-2.0.5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/kea-dhcp /usr/local/kea-dhcp

ENV LD_LIBRARY_PATH=/usr/local/kea-dhcp/lib:$LD_LIBRARY_PATH
RUN ldconfig

ENV PATH=/usr/local/kea-dhcp/sbin:$PATH
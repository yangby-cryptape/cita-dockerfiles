FROM ubuntu:bionic

WORKDIR /tmp

ENV RUST_VERSION="nightly-2018-05-23"
ENV SOLIDITY_VERSION="0.4.19"
ENV PYETHEREUM_VERSION="3d5ec14032cc471f4dcfc7cc5c947294daf85fe0"
ENV GOSU_VERSION="1.10"
ENV KCOV_VERSION="35"
ENV DEFAULT_GROUP="cita"
ENV DEFAULT_USER="cita"
ENV DEFAULT_GID=708
ENV DEFAULT_UID=708

# The install-prefix for third-party executable files
ENV INSTALL_PREFIX="/opt"
ENV PATH "${PATH}:${INSTALL_PREFIX}/bin"
RUN set -eux; \
    mkdir -p "${INSTALL_PREFIX}/bin";

# Install system packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y \
        sudo \
        software-properties-common \
        build-essential \
        automake \
        cmake \
        pkg-config \
        binutils-dev \
        libtool \
        libiberty-dev \
        libdw-dev \
        libffi-dev \
        libgmp-dev \
        zlib1g-dev \
        libsnappy-dev \
        libssl-dev \
        libsodium* \
        libsecp256k1-dev \
        libgoogle-perftools-dev \
        libcurl4-openssl-dev \
        libyaml-cpp-dev \
        libzmq3-dev \
        python3-pip \
        curl \
        unzip \
        git \
        vim-tiny \
        google-perftools \
        jq \
        rabbitmq-server; \
    rm -rf /var/lib/apt/lists/*;

# Install rust toolchain
ENV RUSTUP_HOME="${INSTALL_PREFIX}/local/rustup"
ENV CARGO_HOME="${INSTALL_PREFIX}/local/cargo"
ENV PATH "${PATH}:${CARGO_HOME}/bin"
RUN set -eux; \
    curl https://sh.rustup.rs -sSf \
        | sh -s -- -y --no-modify-path --default-toolchain "${RUST_VERSION}"; \
    rustup component add rustfmt-preview --toolchain "${RUST_VERSION}"; \
    rustup self update; \
    chmod -R a+w "${RUSTUP_HOME}" "${CARGO_HOME}"; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# Install python packages
RUN set -eux; \
    pip3 install -U pip; \
    hash pip3; \
    pip3 install \
        pysodium \
        toml \
        jsonschema \
        secp256k1 \
        jsonrpcclient[requests]==2.4.2; \
    pip3 install \
        https://github.com/ethereum/pyethereum/archive/${PYETHEREUM_VERSION}.zip; \
    rm -rf ~/.cache/pip;

# Install solidity
RUN set -eux; \
    curl -o "solidity-ubuntu-trusty.zip" \
        -L "https://github.com/ethereum/solidity/releases/download/v${SOLIDITY_VERSION}/solidity-ubuntu-trusty.zip"; \
    unzip solidity-ubuntu-trusty.zip -d solidity-ubuntu; \
    mv solidity-ubuntu/solc "${INSTALL_PREFIX}/bin"; \
    rm -rf solidity-ubuntu solidity-ubuntu-trusty.zip;

# Add GmSSL support
COPY libgmssl.so.1.0.0 /usr/local/lib/
RUN set -eux; \
    ln -srf /usr/local/lib/libgmssl.so.1.0.0 /usr/local/lib/libgmssl.so; \
    ldconfig;

# Explicitly set user/group IDs
RUN set -eux; \
    groupadd -r ${DEFAULT_GROUP} --gid=${DEFAULT_GID}; \
    useradd -r -d "/${DEFAULT_USER}" \
        -g ${DEFAULT_GROUP} --uid=${DEFAULT_UID} ${DEFAULT_USER}; \
    echo "${DEFAULT_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers;

# Grab gosu (https://github.com/tianon/gosu/blob/master/INSTALL.md)
RUN set -ex; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    curl -o "${INSTALL_PREFIX}/bin/gosu" \
        -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    curl -o "${INSTALL_PREFIX}/bin/gosu.asc" \
        -L "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        gpg --keyserver "${server}" \
            --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && break || : ; \
    done; \
    gpg --batch --verify "${INSTALL_PREFIX}/bin/gosu.asc" \
        "${INSTALL_PREFIX}/bin/gosu"; \
    rm -r "$GNUPGHOME" "${INSTALL_PREFIX}/bin/gosu.asc"; \
    \
    chmod +x "${INSTALL_PREFIX}/bin/gosu"; \
# verify that the binary works
    gosu nobody true;

# Install Kcov
RUN set -ex; \
    curl -o kcov-${KCOV_VERSION}.tar.gz \
        -L https://github.com/SimonKagstrom/kcov/archive/v${KCOV_VERSION}.tar.gz; \
    tar -xf kcov-${KCOV_VERSION}.tar.gz && cd kcov-${KCOV_VERSION}; \
    mkdir build && cd build; \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="${INSTALL_PREFIX}" \
        .. && make && make install; \
    cd ../..; \
    rm -rf kcov-${KCOV_VERSION}.tar.gz kcov-${KCOV_VERSION};

# Default runtime environment
COPY entrypoint.sh "${INSTALL_PREFIX}/bin/"
RUN set -ex; \
    chmod +x "${INSTALL_PREFIX}/bin/entrypoint.sh";
WORKDIR "/${DEFAULT_USER}"
ENTRYPOINT ["entrypoint.sh"]
CMD ["/bin/bash"]
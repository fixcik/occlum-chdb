FROM occlum/occlum:0.29.7-ubuntu20.04 as builder

RUN rustup install stable && rustup default stable && rustup target add x86_64-unknown-linux-musl;

WORKDIR /build
COPY . .

RUN bash build.sh

WORKDIR /build/instance

FROM ubuntu:20.04

ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
ARG PSW_VERSION=2.17.100.3
ARG DCAP_VERSION=1.14.100.3
ARG OCCLUM_VERSION=0.29.7-1
RUN apt update && DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends gnupg wget ca-certificates jq && \
  echo 'deb [arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu focal main' | tee /etc/apt/sources.list.d/intel-sgx.list && \
  wget -qO - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | apt-key add - && \
  echo 'deb [arch=amd64] https://occlum.io/occlum-package-repos/debian focal main' | tee /etc/apt/sources.list.d/occlum.list && \
  wget -qO - https://occlum.io/occlum-package-repos/debian/public.key | apt-key add - && \
  apt update && apt install -y --no-install-recommends \
  libsgx-launch=$PSW_VERSION-focal1 \
  libsgx-epid=$PSW_VERSION-focal1 \
  libsgx-quote-ex=$PSW_VERSION-focal1 \
  libsgx-urts=$PSW_VERSION-focal1 \
  libsgx-enclave-common=$PSW_VERSION-focal1 \
  libsgx-uae-service=$PSW_VERSION-focal1 \
  libsgx-ae-pce=$PSW_VERSION-focal1 \
  libsgx-ae-qe3=$DCAP_VERSION-focal1 \
  libsgx-ae-id-enclave=$DCAP_VERSION-focal1 \
  libsgx-ae-qve=$DCAP_VERSION-focal1 \
  libsgx-dcap-ql=$DCAP_VERSION-focal1 \
  libsgx-pce-logic=$DCAP_VERSION-focal1 \
  libsgx-qe3-logic=$DCAP_VERSION-focal1 \
  libsgx-dcap-default-qpl=$DCAP_VERSION-focal1 \
  libsgx-dcap-quote-verify=$DCAP_VERSION-focal1 \
  occlum-runtime=$OCCLUM_VERSION \
  && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/occlum/build/bin:/usr/local/occlum/bin:$PATH"

COPY --from=builder /build/instance/instance.tar.gz /
RUN tar -xf instance.tar.gz && rm instance.tar.gz
WORKDIR /instance

COPY sample.sh .
RUN chmod +x sample.sh

CMD [ "./sample.sh" ]
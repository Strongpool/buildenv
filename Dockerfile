FROM docker:dind
ARG CLJ_KONDO_VERSION="2021.08.03"
ARG CLOJURE_TOOLS_VERSION="1.10.3.855"

RUN apk add --no-cache \
    aws-cli \
    bash \
    coreutils \
    curl \
    docker-compose \
    git \
    openjdk11 \
    shellcheck \
    unzip \
    yamllint

RUN curl -sLO https://github.com/clj-kondo/clj-kondo/releases/download/v${CLJ_KONDO_VERSION}/clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && unzip clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && rm clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && mv clj-kondo /usr/local/bin

RUN curl -O https://download.clojure.org/install/linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && chmod +x linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && ./linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && rm linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && clojure -P

ADD voom-like-version /usr/local/bin/voom-like-version

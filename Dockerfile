FROM docker:dind
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
    yamllint

RUN curl -sLO https://raw.githubusercontent.com/clj-kondo/clj-kondo/master/script/install-clj-kondo \
    && chmod +x install-clj-kondo \
    && ./install-clj-kondo \
    && rm ./install-clj-kondo

RUN curl -O https://download.clojure.org/install/linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && chmod +x linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && ./linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && rm linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && clojure -P

ADD voom-like-version /usr/local/bin/voom-like-version


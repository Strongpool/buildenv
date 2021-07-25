FROM docker:dind
ARG CLOJURE_TOOLS_VERSION="1.10.3.855"

RUN apk add --no-cache aws-cli bash curl docker-compose openjdk11

RUN curl -O https://download.clojure.org/install/linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && chmod +x linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && ./linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && rm linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && clojure -P

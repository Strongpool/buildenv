FROM docker:dind

RUN apk add --no-cache --update \
    asciidoctor \
    aws-cli \
    bash \
    chromium \
    coreutils \
    curl \
    docker-compose \
    git \
    graphviz \
    nodejs \
    npm \
    openjdk11 \
    shellcheck \
    sqlite \
    unzip \
    yamllint

# Download and install Nix and install
ARG NIX_VERSION=2.3.12
RUN wget https://nixos.org/releases/nix/nix-${NIX_VERSION}/nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
    && tar xf nix-${NIX_VERSION}-$(uname -m)-linux.tar.xz \
    && addgroup -g 30000 -S nixbld \
    && for i in $(seq 1 30); do adduser -S -D -h /var/empty -g "Nix build user $i" -u $((30000 + i)) -G nixbld nixbld$i ; done \
    && mkdir -m 0755 /etc/nix \
    && echo 'sandbox = false' > /etc/nix/nix.conf \
    && mkdir -m 0755 /nix && USER=root sh nix-${NIX_VERSION}-$(uname -m)-linux/install \
    && ln -s /nix/var/nix/profiles/default/etc/profile.d/nix.sh /etc/profile.d/ \
    && rm -r /nix-${NIX_VERSION}-$(uname -m)-linux* \
    && rm -rf /var/cache/apk/* \
    && /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-old \
    && /nix/var/nix/profiles/default/bin/nix-store --optimise \
    && /nix/var/nix/profiles/default/bin/nix-store --verify --check-contents

# Download and install babashka
ARG BABASHKA_VERSION="0.7.3"
RUN curl -sLO https://github.com/babashka/babashka/releases/download/v${BABASHKA_VERSION}/babashka-${BABASHKA_VERSION}-linux-amd64-static.tar.gz \
    && tar -xzf babashka-${BABASHKA_VERSION}-linux-amd64-static.tar.gz \
    && mv bb /usr/local/bin \
    && rm babashka-${BABASHKA_VERSION}-linux-amd64-static.tar.gz

# Download and install Clojure tools
ARG CLOJURE_TOOLS_VERSION="1.10.3.1058"
RUN curl -O https://download.clojure.org/install/linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && chmod +x linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && ./linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && rm linux-install-${CLOJURE_TOOLS_VERSION}.sh \
    && clojure -P

# Download and install gh (GitHub CLI tool)
ARG GH_VERSION="2.0.0"
RUN curl -sLO https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz \
    && tar -xzf gh_${GH_VERSION}_linux_amd64.tar.gz \
    && mv gh_${GH_VERSION}_linux_amd64/bin/gh /usr/local/bin \
    && rm -rf gh_${GH_VERSION}_linux_amd64.tar.gz gh_${GH_VERSION}_linux_amd64

# Download and install clj-kondo
ARG CLJ_KONDO_VERSION="2021.12.19"
RUN curl -sLO https://github.com/clj-kondo/clj-kondo/releases/download/v${CLJ_KONDO_VERSION}/clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && unzip clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && rm clj-kondo-${CLJ_KONDO_VERSION}-linux-static-amd64.zip \
    && mv clj-kondo /usr/local/bin

# Download and install PlantUML
ARG PLANTUML_VERSION="1.2022.0"
RUN curl -sLO https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar \
    && mkdir -p /usr/local/lib/plantuml \
    && mv plantuml-${PLANTUML_VERSION}.jar /usr/local/lib/plantuml \
    && echo -e "#!/bin/sh\n\njava -jar /usr/local/lib/plantuml/plantuml-${PLANTUML_VERSION}.jar \"\$@\"" > /usr/local/bin/plantuml \
    && chmod 755 /usr/local/bin/plantuml

# Download and install Hugo
ARG HUGO_VERSION="0.83.1"
RUN curl -sLO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz \
    && tar -xzf hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz \
    && mv hugo /usr/local/bin \
    && rm hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz

ENV \
    ENV=/etc/profile \
    USER=root \
    PATH=/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/root/channels

ADD already-succeeded \
    ghcr-login \
    record-success \
    skip-ci \
    start-docker \
    voom-like-version \
    /usr/local/bin/

ARG VERSION_TAG
FROM ghcr.io/pterodactyl/panel:${VERSION_TAG}

# Set the Working Directory
WORKDIR /app

# Install necessary packages
RUN apk update && apk add --no-cache \
    unzip \
    zip \
    curl \
    git \
    bash \
    wget \
    nodejs \
    npm \
    coreutils \
    build-base \
    musl-dev \
    libgcc \
    openssl \
    openssl-dev \
    linux-headers \
    ncurses \
    rsync \
    inotify-tools

# Environment for NVM and Node.js installation
ENV NVM_DIR="/root/.nvm"
ENV NODE_BASE_VERSION="20"
# Set unofficial Node.js builds mirror for musl
ENV NVM_NODEJS_ORG_MIRROR="https://unofficial-builds.nodejs.org/download/release"

# Install NVM and configure the environment
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && [ -s $NVM_DIR/nvm.sh ] && \. $NVM_DIR/nvm.sh \
    && echo "nvm_get_arch() { nvm_echo 'x64-musl'; }" >> $NVM_DIR/nvm.sh \
    && source $NVM_DIR/nvm.sh \
    && latest_version=$(curl -s https://unofficial-builds.nodejs.org/download/release/ | grep -o "v${NODE_BASE_VERSION}\.[0-9]*\.[0-9]*" | sort -V | tail -n1) \
    && nvm install $latest_version \
    && npm config set prefix /usr \
    && npm install -g yarn \
    && yarn

# Download and unzip the latest Blueprint release
RUN wget $(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4) -O blueprint.zip \
    && unzip -o blueprint.zip -d /app \
    && touch /.dockerenv \
    && rm blueprint.zip

# Required for tput (used in blueprint.sh)
ENV TERM=xterm

# Make blueprint.sh set ownership to nginx:nginx
RUN sed -i 's/www-data/nginx/g' blueprint.sh

# Make the script executable and run it
RUN chmod +x blueprint.sh \
    && bash blueprint.sh || true

# Create directory for blueprint extensions
RUN mkdir -p /blueprint_extensions /app

# Create the listen.sh script to monitor and sync blueprint files
RUN echo -e '#!/bin/sh\n\
# Initial sync on startup to ensure /app is up to date with /blueprint_extensions\n\
rsync -av --exclude=".blueprint" --include="*.blueprint*" --exclude="*" --delete /blueprint_extensions/ /app/\n\
# Continuously watch for file changes in /blueprint_extensions\n\
while inotifywait -r -e create,delete,modify,move --include=".*\\.blueprint$" /blueprint_extensions; do\n\
    rsync -av --exclude=".blueprint" --include="*.blueprint*" --exclude="*" --delete /blueprint_extensions/ /app/\n\
done' > /listen.sh && chmod +x /listen.sh

# Set CMD to run the listen script in the background and start supervisord
CMD /listen.sh & exec supervisord -n -c /etc/supervisord.conf

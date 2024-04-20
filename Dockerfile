FROM ghcr.io/pterodactyl/panel:v1.11.5

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

# What version of NodeJS to use
ENV NODE_VERSION="20"

# Install NVM and configure the environment
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc \
    # Set unofficial Node.js builds mirror for musl
    && echo 'export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release' >> $NVM_DIR/nvm.sh \
    # Override the nvm_get_arch function to specify musl architecture
    && echo "nvm_get_arch() { nvm_echo 'x64-musl'; }" >> $NVM_DIR/nvm.sh \
    # Load NVM
    && . $NVM_DIR/nvm.sh \
    # Fetch the latest version available for musl with the specified Node version
    && latest_version=$(curl -s https://unofficial-builds.nodejs.org/download/release/ | grep -o "v${NODE_VERSION}\.[0-9]*\.[0-9]*" | sort -V | tail -n1) \
    # Install the latest Node.js version fetched
    && nvm install $latest_version \
    # Install Yarn globally
    && npm install -g yarn \
    # Run Yarn
    && yarn

# Download and unzip the latest Blueprint release
RUN wget $(curl -s https://api.github.com/repos/BlueprintFramework/main/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4) -O blueprint.zip \
    && unzip -o blueprint.zip -d /app \
    && touch /.dockerenv \
    && rm blueprint.zip

# Required for tput (used in blueprint.sh)
ENV TERM=xterm

# Make blueprint.sh set ownership to nginx:nginx
RUN sed -i 's/OWNERSHIP="www-data:www-data"/OWNERSHIP="nginx:nginx"/' blueprint.sh

# Make the script executable and run it
RUN chmod +x blueprint.sh \
    && bash blueprint.sh || true

# Create directory for blueprint extensions
RUN mkdir -p /blueprint_extensions /app

# Create the listen.sh script to monitor and sync blueprint files
RUN echo -e '#!/bin/sh\n\
# Initial sync on startup to ensure /app is up to date with /blueprint_extensions\n\
rsync -av --include="*/" --include="*blueprint*" --exclude="/app/.blueprint/" --exclude="*" --delete /blueprint_extensions/ /app/\n\
# Continuously watch for file changes in /blueprint_extensions\n\
while inotifywait -r -e create,delete,modify,move --include=".*\\.blueprint$" /blueprint_extensions; do\n\
    rsync -av --include="*/" --include="*blueprint*" --exclude="/app/.blueprint/" --exclude="*" --delete /blueprint_extensions/ /app/\n\
done' > /listen.sh && chmod +x /listen.sh

# Set CMD to run the listen script in the background and start supervisord
CMD /listen.sh & exec supervisord -n -c /etc/supervisord.conf

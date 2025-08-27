ARG VERSION_TAG
FROM --platform=$TARGETOS/$TARGETARCH ghcr.io/pterodactyl/panel:${VERSION_TAG}

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
    inotify-tools \
    sed

# Install yarn and Pterodactyl dependencies, as well as update browserlist
RUN for i in {1..3}; do \
        npm install -g yarn && \
        yarn --network-timeout 120000 && \
        npx update-browserslist-db@latest && \
        break || \
        echo "Attempt $i failed! Retrying..." && \
        sleep 10; \
    done

# Download and unzip the latest Blueprint release
RUN wget $(curl -s https://api.github.com/repos/BlueprintFramework/framework/releases/latest | grep 'browser_download_url' | cut -d '"' -f 4) -O blueprint.zip \
    && unzip -o blueprint.zip -d /app \
    && touch /.dockerenv \
    && rm blueprint.zip

# Required for tput (used in blueprint.sh)
ENV TERM=xterm

# Copy helpers directory - has to be done before running blueprint.sh for .blueprintrc to set correct permisisons
COPY .helpers /helpers
RUN mv /helpers/.blueprintrc /app/.blueprintrc
RUN chmod +x /helpers/*.sh

# Make the script executable and run it
RUN chmod +x blueprint.sh \
    && bash blueprint.sh

# Create directory for blueprint extensions
RUN mkdir -p /blueprint_extensions

# Append our additions to supervisord
RUN echo "" >> /etc/supervisord.conf && \
    cat >> /etc/supervisord.conf <<'EOF'

[program:database-seeder]
command=/helpers/seeder.sh
user=nginx
autostart=true
autorestart=false
startsecs=0

[program:listener]
command=/helpers/listen.sh
user=root
autostart=true
autorestart=true

[program:fix-bind-mount-perms]
command=/helpers/permissions.sh
user=root
autostart=true
autorestart=false
startsecs=0
priority=1
EOF

# Override the default entrypoint script
COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "/bin/ash", "entrypoint.sh" ]
CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]

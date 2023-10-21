ARG NODE_VERSION=14.21.3
ARG RC_VERSION=6.4.2

# node builder
FROM node:${NODE_VERSION}-bullseye as node-builder
ARG RC_VERSION
WORKDIR /app
# install dependencies
RUN \
    apt update && \
    apt install \
        build-essential \
        python3 \
        gnupg \
        curl && \
    # signature verification
    gpg --batch \
        --keyserver keyserver.ubuntu.com \
        --recv-keys 0E163286C20D07B9787EBE9FD7F9D0414FD08104 && \
    # download in one step (200M)
    curl -o \
    /tmp/rocket.chat.tgz -L \
        "https://releases.rocket.chat/${RC_VERSION}/download" && \
    curl -o \
    /tmp/rocket.chat.tgz.asc -L \
        "https://releases.rocket.chat/${RC_VERSION}/asc" && \
    # verify download
    gpg --batch --verify \
        /tmp/rocket.chat.tgz.asc \
        /tmp/rocket.chat.tgz && \
    tar xf /tmp/rocket.chat.tgz -C \
        /app && \
    # remove browser, browser legacy
    rm -r \
        /app/bundle/programs/web.browser.legacy \
        /app/bundle/programs/web.browser && \
    # clean up meteor node_modules
    find /app/bundle/programs/server/npm/node_modules \
    -type d \( \
        -name "*-garbage-*" -o \
        -name ".temp-*" -o \
        -name "docs" -o \
        -name "examples" -o \
        -name "samples" -o \
        -name "phantomjs-prebuilt" \
    \) -exec rm -rf {} + && \
    find /app/bundle/programs/server/npm/node_modules \
    -type f \( \
        -name "*.md" -o \
        -name "*.markdown" -o \
        -name "*.ts" -o \
        -name "*.exe" \
    \) -delete && \
    # install runtime dependencies
    cd /app/bundle/programs/server && \
    npm install --production

FROM node:${NODE_VERSION}-bullseye as final
VOLUME /app/uploads
# user and permission setup
RUN \
    apt update && \
    apt install \
        fontconfig && \
    groupadd -r -g 1100 rocketchat && \
    useradd -r -g rocketchat -u 1100 rocketchat && \
    mkdir -p \
        /app/uploads && \
    chown -R \
        rocketchat:rocketchat \
        /app/uploads
COPY --from=node-builder \
    --chown=rocketchat:rocketchat \
    /app/bundle /app/bundle 
USER rocketchat
WORKDIR /app/bundle

ENV \
    NODE_ENV=production \
    MONGO_URL=mongodb://mongodb:27017/rocketchat \
    HOME=/tmp \
    PORT=3000 \
    ROOT_URL=http://localhost:3000 \
    Accounts_AvatarStorePath=/app/uploads

EXPOSE 3000
CMD ["node", "main.js"]
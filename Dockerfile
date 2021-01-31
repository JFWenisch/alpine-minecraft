# Pull base image
FROM alpine

# Install dependencies
RUN apk update; \
    apk add bash openjdk11 wget ca-certificates jq; \
    mkdir /minecraft

# Define working directory
WORKDIR /tmp
RUN wget -q "https://launchermeta.mojang.com/mc/game/version_manifest.json"
RUN wget -qO manifest.json \
    $(printf $(jq -r --arg ver "$VERSION" --arg rel "$(jq -r '.latest.release' < version_manifest.json)" \
    '(.versions[] | select(.id == $ver).url),(.versions[] | select(.id == $rel).url)' < version_manifest.json) \
    | awk '{print $1}')

RUN printf "Downloading Minecraft server ($(jq -r '.id' < manifest.json))...\n"
RUN wget -qO /minecraft/server.jar "$(jq -r '.downloads.server.url' < manifest.json)"
RUN rm -rf *
RUN echo 'eula=true' > /minecraft/eula.txt
WORKDIR /minecraft
# Define entry point

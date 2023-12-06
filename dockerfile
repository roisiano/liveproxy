ARG ALPINE_IMAGE=python:3-alpine3.18

FROM ${ALPINE_IMAGE} as build

# Install build dependencies
RUN apk --no-cache add curl gcc git libxml2-dev libxslt-dev musl-dev

# Add liveproxy user for building
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Build streamlink and liveproxy
RUN pip3 install --user --no-cache-dir --no-warn-script-location https://github.com/Scotto0/streamlink/archive/refs/heads/master.zip && \
  pip install --user --no-cache-dir --no-warn-script-location git+https://github.com/back-to/liveproxy.git@35cad27

# Create Liveproxy container
FROM ${ALPINE_IMAGE} as liveproxy

# Install binary dependencies
RUN apk --no-cache add ffmpeg libxml2 libxslt

# Add liveproxy user
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Move liveproxy, streamlink, youtube-dl, and yt-dlp from the build image
COPY --from=build /home/liveproxy/.local /home/liveproxy/.local
RUN mkdir -p /home/liveproxy/.config/streamlink/plugins
ENV PATH=$PATH:/home/liveproxy/.local/bin

EXPOSE 57522

ENTRYPOINT [ "liveproxy", "--host", "0.0.0.0" ]

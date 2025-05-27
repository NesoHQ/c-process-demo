FROM debian:stable

# Install required tools
RUN apt-get update && apt-get install -y \
    build-essential make procps grep && \
    apt-get clean

RUN apt-get update && apt-get install -y bat

WORKDIR /app

COPY . .

RUN make

# Copy our interactive script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

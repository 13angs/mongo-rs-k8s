FROM mongo:6-jammy

WORKDIR /root

COPY . .

# Install necessary packages and clean up
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x init.sh setup-rs.sh

ENV DB_TYPE='STANDALONE' \
    REPLSET_NAME='rs0'

CMD ./init.sh
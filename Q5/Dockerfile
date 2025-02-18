FROM ubuntu:latest
RUN apt-get update && apt-get install -y bash
COPY CSV_input.sh /usr/local/bin/
COPY Demo_CSV.csv /data/
WORKDIR /data

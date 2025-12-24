FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    ansible \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install jinja2 pyyaml

WORKDIR /app
COPY ansible/ /app/ansible/
COPY docker/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
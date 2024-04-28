FROM hashicorp/vault

COPY ./config.json /vault/config

EXPOSE 8200

CMD ["vault", "server", "-config=/vault/config"]

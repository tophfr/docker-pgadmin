ARG PGADMIN_VERSION=8.14.0
FROM dpage/pgadmin4:${PGADMIN_VERSION}

USER root

RUN mv /entrypoint.sh /entrypoint-pgadmin4.sh
COPY entrypoint.sh /

USER pgadmin

ENV PGADMIN_LISTEN_PORT 5050
EXPOSE 5050

ENV PGADMIN_DISABLE_POSTFIX True

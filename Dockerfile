FROM elixir:1.10.4-alpine

ARG puid
ARG pgid
ARG instance_user
ARG PLEROMA_VER=develop

ENV PUID=${puid} PGID=${pgid} INS_USER=${instance_user} MIX_ENV=prod

# Below two is for China
#RUN echo 'https://mirros.aliyun.com/alpine/v3.11/main/' > /etc/apk/repositories
#RUN echo 'https://mirros.aliyun.com/alpine/v3.11/community/' >> /etc/apk/repositories

RUN apk -U upgrade \
    && apk add --no-cache \
    build-base \
    cmake \
    git \
    curl \
    unzip \
    ncurses \
    file-dev \
    imagemagick \
    ffmpeg \
    exiftool

RUN getent group pleroma 2>&1 >/dev/null || addgroup -g ${PGID} pleroma ; exit 0
RUN adduser -h /pleroma -s /bin/sh -G pleroma -u ${PUID} -D ${INS_USER}

RUN test -d /var/lib/pleroma || mkdir -p /var/lib/pleroma/static
RUN chown -R ${PUID}:${PGID} /var/lib/pleroma
RUN test -L /etc/pleroma || ln -s /pleroma/config /etc/pleroma

USER ${INS_USER}
WORKDIR /pleroma

RUN git clone -b stable --depth=1 https://git.pleroma.social/pleroma/pleroma.git /pleroma \
    && git checkout stable

COPY pleroma_config/generated_config.exs /pleroma/config/generated_config.exs
COPY pleroma_config/prod.secret.exs /pleroma/config/prod.secret.exs
COPY pleroma_config/emoji.txt /pleroma/config/emoji.txt
COPY priv/static/favicon.png /pleroma/priv/static/favicon.png
COPY priv/static/static/*.png /pleroma/priv/static/static/
COPY priv/static/static/terms-of-service.html /pleroma/priv/static/static/terms-of-service.html
COPY priv/static/instance/panel.html /pleroma/priv/static/instance/panel.html
COPY priv/static/emoji/blobs /pleroma/priv/static/emoji/blobs

# Below two is for China
#ENV HEX_MIRROR=http://hexpm.upyun.com
#ENV HEX_CDN=http://hexpm.upyun.com

RUN mix local.rebar --force
RUN mix local.hex --force
RUN mix deps.get && mix compile

VOLUME /pleroma/uploads/

CMD ["mix", "phx.server"]

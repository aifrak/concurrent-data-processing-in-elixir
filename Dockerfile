# —————————————————————————————————————————————— #
#                      base                      #
# —————————————————————————————————————————————— #

FROM ubuntu:focal-20220113 as base

USER root

# Required packages:
#   - for erlang: libodbc1, libssl1, libsctp1
RUN set -e \
  && export DEBIAN_FRONTEND=noninteractive \
  && echo "--- Install packages ---" \
  && apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
  git=1:2.25.1-* \
  libodbc1=2.3.6-* \
  libssl1.1=1.1.1f-* \
  libsctp1=1.0.18+* \
  locales=2.31-* \
  && echo "--- Add locales ---" \
  && sed -i "/en_US.UTF-8/s/^# //g" /etc/locale.gen \
  && locale-gen "en_US.UTF-8" \
  && echo "--- Clean ---" \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

ENV USERNAME=app-user
ARG GROUPNAME=${USERNAME}
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV HOME=/home/${USERNAME}
ENV APP_DIR=/app

RUN set -e \
  && echo "--- Add username and groupname ---" \
  && groupadd --gid ${USER_GID} ${GROUPNAME} \
  && useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash \
  --create-home ${USERNAME} \
  && echo "--- Create project directory and add ownership ---" \
  && mkdir ${APP_DIR} \
  && chown ${USERNAME}: ${APP_DIR}

USER ${USERNAME}

WORKDIR ${APP_DIR}

CMD [ "bash" ]

# —————————————————————————————————————————————— #
#                       ci                       #
# —————————————————————————————————————————————— #

FROM koalaman/shellcheck:v0.8.0 as shellcheck
FROM mvdan/shfmt:v3.4.2 as shfmt
FROM hadolint/hadolint:v2.8.0 as hadolint

FROM hexpm/elixir:1.11.4-erlang-23.3.4.11-ubuntu-focal-20211006 as elixir
# Install hex and rebar
RUN set -e \
  && mix local.hex --force \
  && mix local.rebar --force

FROM node:16.13.2-buster as node
RUN npm install -g npm@8.4.1 --quiet

FROM base as ci

USER root

# Add shellcheck
COPY --from=shellcheck --chown=root /bin/shellcheck /usr/local/bin/

# Add shfmt
COPY --from=shfmt --chown=root /bin/shfmt /usr/local/bin/

# Add hadolint
COPY --from=hadolint --chown=root /bin/hadolint /usr/local/bin/

# Add NodeJS (without yarn)
COPY --from=node --chown=root /usr/local/bin /usr/local/bin/
COPY --from=node --chown=root /usr/local/include /usr/local/include/
COPY --from=node --chown=root /usr/local/lib /usr/local/lib/
COPY --from=node --chown=root /usr/local/share /usr/local/share/
# Remove dead symbolic links from yarn
RUN find /usr/local/bin/. -xtype l -exec rm {} \; 2>/dev/null

# Add erlang and elixir
COPY --from=elixir --chown=root /usr/local/bin /usr/local/bin
COPY --from=elixir --chown=root /usr/local/lib /usr/local/lib
COPY --from=elixir --chown=root /usr/local/sbin /usr/local/sbin
COPY --from=elixir --chown=${USERNAME} /root/.mix ${HOME}/.mix

USER ${USERNAME}

# —————————————————————————————————————————————— #
#                       dev                      #
# —————————————————————————————————————————————— #

FROM ci as dev

USER root

RUN set -e \
  && export DEBIAN_FRONTEND=noninteractive \
  && echo "--- Install packages ---" \
  && apt-get update -qq \
  && apt-get install -y -qq --no-install-recommends \
  ca-certificates=* \
  gnupg2=* \
  openssh-client=* \
  sudo=* \
  && echo "--- Give sudo rights to 'USERNAME' ---" \
  && echo "${USERNAME}" ALL=\(root\) NOPASSWD:ALL >/etc/sudoers.d/"${USERNAME}" \
  && chmod 0440 /etc/sudoers.d/"${USERNAME}" \
  && echo "--- Clean ---" \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

# —————————————————————————————————————————————— #
#                     vscode                     #
# —————————————————————————————————————————————— #

FROM dev as vscode

WORKDIR ${HOME}

RUN set -e \
  && mkdir -p .vscode-server/extensions \
  .vscode-server-insiders/extensions

WORKDIR ${APP_DIR}

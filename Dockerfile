FROM node:6-slim
LABEL maintainer="Emerson Rocha <rocha@ieee.org>"

# see https://github.com/nodejs/docker-node#how-to-use-this-image

## Install common software
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  bzip2 \
  dh-autoreconf \
  git \
  libpng-dev

## Download Uwazi
RUN git clone -b 1.1 --single-branch --depth=1 https://github.com/huridocs/uwazi.git /home/node/uwazi/ \
  && chown node:node -R /home/node/uwazi/ \
  && cd /home/node/uwazi/ \
  && yarn install \
  && yarn production-build

COPY --chown=node:node ./scripts/patch/uwazi/database/reindex_elastic.js /home/node/uwazi/database/reindex_elastic.js

## TODO: move to the start of the Dockerfile (fititnt, 2018-04-16 00:27 BRT)
# Install mongo & mongorestore (this is used only for database initialization, not on runtime)
# So much space need, see 'After this operation, 184 MB of additional disk space will be used.'
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 \
  && echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.6 main" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list \
  && apt-get update \
  && apt-get install -y mongodb-org-shell mongodb-org-tools

WORKDIR /home/node/uwazi/
COPY --chown=node:node docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

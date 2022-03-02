FROM antora/antora:latest
RUN npm install -g npm@latest
RUN yarn global add http-server onchange
WORKDIR /site

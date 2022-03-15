FROM antora/antora:3.0.0
# RUN npm install -g npm@latest
RUN yarn global add http-server@14.1.0 onchange@7.1.0
WORKDIR /site

FROM node:8.6 as builder

LABEL builder=true

ENV HOME=/src/app

ARG repository="Ismaestro/angular4-example-app"

# This is only to overcome build cache
# see https://github.com/moby/moby/issues/14704
ADD https://api.github.com/repos/${repository}/compare/master...HEAD /dev/null
RUN mkdir -p $HOME && \
    wget -qO- https://github.com/${repository}/archive/master.tar.gz | \
        tar -xz --strip-components=1 -C $HOME

WORKDIR $HOME
RUN npm install && npm run build

FROM nginx:alpine
COPY --from=builder /src/app/dist /usr/share/nginx/html

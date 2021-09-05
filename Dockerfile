# Build frontend
FROM node:14.17 AS fe
ENV GENERATE_SOURCEMAP false
WORKDIR /frontend
COPY ./frontend/package.json package.json
COPY ./frontend/yarn.lock yarn.lock
RUN yarn install
COPY ./frontend .
RUN yarn generate

FROM ubuntu:20.04
LABEL Name=web_app_test
ENV TZ Asia/Tokyo

RUN apt-get update && apt-get install -y \
  tzdata  \
  unzip   \ 
  curl   \ 
  nginx   \
  && rm -f /etc/nginx/sites-enabled/default

ENV APP_ROOT /app
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT
COPY --from=fe /frontend/dist frontend/dist

COPY ./.docker/entrypoint.sh /entrypoint.sh
COPY ./.docker/etc/nginx/conf.d/sample.conf /etc/nginx/conf.d/sample.conf

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "bash" ]
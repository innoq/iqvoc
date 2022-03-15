FROM ruby:2.6

ENV RAILS_ENV=production \
    DB_ADAPTER=postgresql \
    PORT=3000 \
    BUNDLE_PATH=/iqvoc/gems \
    GEM_HOME=/iqvoc/gems \
    HOME=/iqvoc/home \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y -q nodejs npm

RUN mkdir -p /iqvoc /iqvoc/gems /iqvoc/home /usr/sbin/.passenger /opt/nginx
RUN chown -R daemon /iqvoc /usr/sbin/.passenger /opt/nginx

WORKDIR /iqvoc
USER daemon

RUN gem install bundler
COPY --chown=daemon Gemfile Gemfile.lock ./
COPY --chown=daemon config/database.yml.postgresql /iqvoc/config/database.yml
RUN bundle install --without development test
RUN exec passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx
COPY --chown=daemon . /iqvoc

RUN DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

CMD bundle exec rake db:migrate && bundle exec rake db:seed && bin/delayed_job start && exec bundle exec passenger start --port $PORT --environment $RAILS_ENV
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
    apt-get install --no-install-recommends -y -q nodejs npm && \
    mkdir -p /iqvoc /iqvoc/gems /iqvoc/home  && \
    chown -R daemon /iqvoc

WORKDIR /iqvoc
USER daemon

COPY --chown=daemon Gemfile Gemfile.lock ./
COPY --chown=daemon config/database.yml.multi /iqvoc/config/database.yml

RUN bundle install --with remote_dbs --without development test passenger

RUN exec passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx
COPY --chown=daemon . /iqvoc

RUN DB_ADAPTER=nulldb RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000

CMD bundle exec rake db:migrate && bundle exec rake db:seed && bin/delayed_job start && exec bundle exec passenger start --port $PORT --environment $RAILS_ENV
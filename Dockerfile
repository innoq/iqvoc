FROM ruby:2.6

ENV RAILS_ENV="production" \
    RAILS_LOG_TO_STDOUT="true" \
    RAILS_SERVE_STATIC_FILES="true" \
    APP_HOME="/app/" \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH="/bundle" \
    PATH="/app/bin:${PATH}" \
    PORT=3000

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get autoremove && \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/* && \
    useradd -m iqvoc && \
    mkdir "$APP_HOME" && \
    mkdir "$BUNDLE_PATH" && \
    chown -R iqvoc:iqvoc "$APP_HOME" "$BUNDLE_PATH" /usr/local/bundle

WORKDIR $APP_HOME

# copy lockfiles
COPY --chown=iqvoc:iqvoc Gemfile* ./
COPY --chown=iqvoc:iqvoc package.json ./
COPY --chown=iqvoc:iqvoc package-lock.json ./

# install bundler/rubygems/npm deps
RUN gem install bundler
RUN bundle install
RUN npm install -g npm@latest
RUN npm install

# copy app files
COPY --chown=iqvoc:iqvoc . ./
COPY --chown=iqvoc:iqvoc config/database.yml.postgresql ./config/database.yml

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE $PORT

# From now on execute commands as non root
USER iqvoc

# compile assets
RUN npm run compile

# Start the main process.
CMD bin/delayed_job start && bin/rails server -b 0.0.0.0 -p $PORT

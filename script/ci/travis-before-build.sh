sh -e /etc/init.d/xvfb start
cp config/database.template.yml config/database.yml
cp config/initializers/secret_token.rb.template config/initializers/secret_token.rb

sh -e /etc/init.d/xvfb start
cp config/database.template.yml config/database.yml
secret=`bundle exec rake secret`
sed -e "s/###SECRET###/$secret/g" config/initializers/secret_token.rb.template > config/initializers/secret_token.rb

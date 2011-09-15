# Start virtual X frame buffer
`sh -e /etc/init.d/xvfb start`

# Copy database config
`cp config/database.template.yml config/database.yml`

# Generate and copy secret token initializer
secret = `bundle exec rake secret`.strip
path = File.join(File.dirname(__FILE__), '../../config/initializers/')
template = File.read(File.join(path, 'secret_token.rb.template'))

template.gsub!('S-E-C-R-E-T', secret)
File.open(File.join(path, 'secret_token.rb'), 'w') do |file|
  file.puts template
end

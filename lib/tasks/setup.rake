namespace :setup do
  task :generate_secret_token do
    template = Rails.root.join("config", "initializers", "secret_token.rb.template")
    raise "File not found: #{template}" unless File.exist?(template)

    file_name = "config/initializers/secret_token.rb"

    token = ActiveSupport::SecureRandom.hex(64)
    txt = File.read(template)
    txt.gsub!("S-E-C-R-E-T", token)

    File.open(file_name, "w") do |f|
      f.write txt
    end
    
    puts "Secret token configuration has been created in #{file_name}."
  end
end

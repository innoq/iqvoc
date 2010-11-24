
# load .capistrano_history.yml to @capistrano_history
def load_history
  @capistrano_history = {}
  @capistrano_history = YAML::load(File.open(".capistrano_history.yml")) if File.exist?(".capistrano_history.yml")
end

# Write history file to prevent too much typing the next time :-)
def save_history
  File.open(".capistrano_history.yml", 'w') do |f|
    f.write(@capistrano_history.to_yaml)
  end
end


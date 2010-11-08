desc "Runs a rake task on the remote system. Use task='<taskname + parameters>' to specify the task."
task :invoke_task do
  if ENV['task'] && ENV['task'] =~ /^iqvoc/
    run("cd #{deploy_to}/current; rake --trace #{ENV['task']} RAILS_ENV=production")
  else
    run("cd #{deploy_to}/current; rake -T iqvoc --trace RAILS_ENV=production")
  end
end

desc "Tail production log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end
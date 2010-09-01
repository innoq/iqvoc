#sudo gem install ZenTest
#sudo apt-get install libnotify-bin

module Autotest::Notify

  def self.has_notify?
    system "which notify-send 2> /dev/null"
  end

  def self.notify title, msg, img, pri='low', time=5000
    `notify-send -i #{img} -u #{pri} -t #{time} '#{title}' '#{msg}'` if has_notify?
  end

  Autotest.add_hook :ran_command do |autotest|
    results = [autotest.results].flatten.join("\n")
    output = results.slice(/(\d+)\s+examples?,\s*(\d+)\s+failures?(,\s*(\d+)\s+pending)?/)
    #folder = "~/Pictures/rails/"
    
    # by vd
    fname = File.symlink?(__FILE__) ? `readlink #{__FILE__}` : __FILE__
    folder = File.expand_path(File.dirname(fname) + '/rails_style/')
    
    html_file = File.expand_path(File.join(folder, '../doc/spec/report.html'))
    note = "s. file://#{html_file} for details"
    if output  =~ /[1-9]\d*\sfailures?/
      notify "#{output}", "#{note}", File.join(folder,"fail.png"), 'low', 15000
    elsif output  =~ /[1-9]\d*\spending?/
      notify "#{output}", "#{note}", File.join(folder,"pending.png"), 'low', 5000
    else
      notify "#{output}", "#{note}", File.join(folder,"pass.png")
    end
  end

  false
end

#require 'autotest/redgreen'

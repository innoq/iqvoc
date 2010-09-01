require 'rnotify'
require 'gtk2'
require 'launchy'

module Autotest::RNotify
  class Notification
    attr_accessor :verbose, :image_root, :tray_icon, :notification, 
                  :image_pass, :image_pending, :image_fail,
                  :image_file_pass, :image_file_pending, :image_file_fail,
                  :status_image_pass, :status_image_pending, :status_image_fail
    
    def initialize(timeout = 5000, 
                   image_root = "#{ENV['HOME']}/.autotest_images" , 
                   report_url = "doc/spec/report.html",
                   verbose = false)
      self.verbose = verbose
      self.image_root = image_root
      self.image_file_pass = "#{image_root}/pass.png"
      self.image_file_pending = "#{image_root}/pending.png"
      self.image_file_fail = "#{image_root}/fail.png"

      raise("#{image_file_pass} not found") unless File.exists?(image_file_pass)
      raise("#{image_file_pending} not found") unless File.exists?(image_file_pending)
      raise("#{image_file_fail} not found") unless File.exists?(image_file_fail)
      
      puts 'Autotest Hook: loading Notify' if verbose
      Notify.init('Autotest') || raise('Failed to initialize Notify')

      puts 'Autotest Hook: initializing tray icon' if verbose
      self.tray_icon = Gtk::StatusIcon.new
      tray_icon.pixbuf = Gdk::Pixbuf.new(image_file_pending,22,22)
      tray_icon.tooltip = 'RSpec Autotest'

      puts 'Autotest Hook: Creating Notifier' if verbose
      self.notification = Notify::Notification.new('X', nil, nil, tray_icon)

      notification.timeout = timeout

      puts 'Autotest Hook: Connecting mouse click event' if verbose
      tray_icon.signal_connect("activate") do
        Launchy::Browser.new.visit(report_url)
      end
      
      Thread.new { Gtk.main }
      sleep 1
      tray_icon.embedded? || raise('Failed to set up tray icon')
    end
    
    def notify(icon, tray, title, message)
      notification.update(title, message, nil)
      notification.pixbuf_icon = icon
      tray_icon.tooltip = "Last Result: #{message}"
      tray_icon.pixbuf = tray
      notification.show
    end
    
    def passed(title, message)
      self.image_pass ||= Gdk::Pixbuf.new(image_file_pass, 48, 48)
      self.status_image_pass ||= Gdk::Pixbuf.new(image_file_pass, 22, 22)
      notify(image_pass, status_image_pass, title, message)
    end
    
    def pending(title, message)
      self.image_pending ||= Gdk::Pixbuf.new(image_file_pending, 48, 48)
      self.status_image_pending ||= Gdk::Pixbuf.new(image_file_pending, 22, 22)
      notify(image_pending, status_image_pending, title, message)
    end
    
    def failed(title, message) 
      self.image_fail ||= Gdk::Pixbuf.new(image_file_fail, 48, 48)
      self.status_image_fail ||= Gdk::Pixbuf.new(image_file_fail, 22, 22)
      notify(image_fail, status_image_fail, title, message)
    end
    
    def quit
      puts 'Autotest Hook: Shutting Down...' if verbose
      #Notify.uninit
      Gtk.main_quit
    end
  end

  Autotest.add_hook :initialize do |at|
    @notify = Notification.new
  end

    def todo
  Autotest.add_hook :ran_command do |at|
    results = at.results.last

    unless results.nil?
      output = results[/(\d+)\s+examples?,\s*(\d+)\s+failures?(,\s*(\d+)\s+pending)?/]
      if output
        failures = $~[2].to_i
        pending = $~[4].to_i
      end
      
      if failures > 0
        @notify.failed("Tests Failed", output)
      elsif pending > 0
        @notify.pending("Tests Pending", output)
      else
        unless at.tainted
          @notify.passed("All Tests Passed", output)
        else
          @notify.passed("Tests Passed", output)
        end
      end
    end
  end

  Autotest.add_hook :quit do |at|
    @notify.quit
end
end
end
Please link one of the config files to either root directory of your rail application
or your home directory. Link name should be '.autotest'.

Example:

cd my_rails_app
ln -s script/autotest/autotest_config_simple.rb .autotest

The simple file is for using with Linux's notify-send.
Based on http://pragmatig.wordpress.com/2008/04/15/autotest-rspec-notifications-for-ubuntu/

More complicated is for usage with ruby-libnotify
s. http://www.ikhono.net/2007/12/16/gnome-autotest-notifications
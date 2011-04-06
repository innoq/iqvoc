require 'fileutils'

namespace :iqvoc do
  namespace :assets do

    def for_static_folders
      engine_public_dir = Iqvoc::Engine.find_root_with_flag("public").join('public')
      app_public_dir = Rails.public_path

      if File.directory?(app_public_dir)
        %w(stylesheets javascripts images fonts).each do |specific_dir|
          source_common_dir = File.join(engine_public_dir, specific_dir, "iqvoc")
          if File.exist?(source_common_dir)
            target_common_dir = File.join(app_public_dir, specific_dir, "iqvoc")
            FileUtils.mkdir_p(File.join(app_public_dir, specific_dir))

            yield(source_common_dir, target_common_dir)
          end
        end
      end
    end

    desc "Create symlinks to public stylesheets, javascripts, fonts and images folders in engine"
    task :link_static_folders do
      for_static_folders do |source_common_dir, target_common_dir|
        File.unlink(target_common_dir) if File.symlink?(target_common_dir) && ENV['force'] == "true"
        if !File.exists?(target_common_dir)
          puts "Linking #{source_common_dir} -> #{target_common_dir}"
          File.symlink(source_common_dir, target_common_dir)
        else
          puts "Symlink #{target_common_dir} already exists!"
        end
      end
    end

    desc "Copy public stylesheets, javascripts, fonts and images folders in engine to the public directory of this application"
    task :copy_static_folders do
      for_static_folders do |source_common_dir, target_common_dir|
        if !File.exists?(File.join(target_common_dir, "engine"))
          puts "Copying #{source_common_dir} -> #{target_common_dir}"
          FileUtils.cp_r(source_common_dir, target_common_dir)
        else
          puts "Directory #{File.join(target_common_dir, "vendor")} already exists!"
        end
      end
    end

  end
end

# encoding: utf-8

class Base < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    Iqvoc.upload_path.join(self.model.class.to_s.downcase)
  end

  def filename
    "#{self.secure_token}.#{file.extension}"
  end

  protected

  # https://github.com/jnicklas/carrierwave/wiki/How-to%3A-Create-random-and-unique-filenames-for-all-versioned-files
  def secure_token
    var = :"@#{mounted_as}_secure_token"

    self.model.instance_variable_get(var) or self.model.instance_variable_set(var, SecureRandom.hex)
  end
end

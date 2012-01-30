# encoding: UTF-8

# Copyright 2011 innoQ Deutschland GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'csv'

class InstanceConfigurationController < ApplicationController

  def index
    authorize! :show, Iqvoc.config

    @settings = Iqvoc.config.defaults.each_with_object({}) { |(key, default_value), hsh|
      hsh[key] = serialize(Iqvoc.config[key], default_value)
    }
  end

  def update
    authorize! :update, Iqvoc.config

    # deserialize and save configuration settings
    errors = []
    params[:config].each { |key, value|
      unless Iqvoc.config.defaults.include?(key)
        errors << t("txt.controllers.instance_configuration.invalid_key", :key => key)
      else
        default_value = Iqvoc.config.defaults[key]
        begin
          Iqvoc.config[key] = deserialize(value, default_value)
        rescue TypeError => exc
          errors << t("txt.controllers.instance_configuration.invalid_value",
              :key => key, :error_message => exc.message)
        end
      end
    }

    if errors.blank?
      flash[:notice] = t("txt.controllers.instance_configuration.update_success")
    else
      flash[:error] = t("txt.controllers.instance_configuration.update_error",
          :error_messages => errors.join("; "))
    end

    redirect_to instance_configuration_url
  end
  
  private

  # default value determines value type
  def serialize(value, default_value)
    Iqvoc::InstanceConfiguration.validate_value(value)
    if default_value.is_a? Array
      return value.to_csv
    else # String, Fixnum / Float
      return value.to_s
    end
  end

  # default value determines expected type
  # raises TypeError if deserialization fails
  def deserialize(str, default_value)
    str = str.strip
    unless default_value.is_a? Array
      return convert_value(str, default_value.class)
    else
      return str.blank? ? [] : str.parse_csv.map { |item|
        item.strip!
        convert_value(item, default_value[0].class)
      }
    end
  end

  # converts string to given (non-complex) type
  # raises TypeError on failure
  def convert_value(str, type)
    if type == String
      return str
    elsif type == Fixnum
      raise TypeError, "expected integer" unless str =~ /^[-+]?[0-9]+$/
      return str.to_i
    elsif type == Float
      begin
        return Float(str)
      rescue ArgumentError
        raise TypeError, "expected float"
      end
    else
      raise TypeError, "unsupported type: #{type}"
    end
  end

end

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

# Provides the utilities to replace special chars etc in
# texts to generate a valid turtle compatible id (an url slug).
module Iqvoc
  class Origin
    attr_accessor :value
    
    def initialize(value, run_chain = true)
      @value = value.to_s
      
      if run_chain
        handle_numbers_at_beginning!.
          replace_umlauts!.
          replace_whitespace!.
          replace_special_chars!
      end
    end
    
    def to_s
      @value
    end
    
    def replace_umlauts!
      self.tap do |obj|
        obj.value = obj.value.
          gsub(/Ö/, 'Oe').
          gsub(/Ä/, 'Ae').
          gsub(/Ü/, 'Ue').
          gsub(/ö/, 'oe').
          gsub(/ä/, 'ae').
          gsub(/ü/, 'ue').
          gsub(/ß/, 'ss')
      end
    end

    def replace_whitespace!
      self.tap do |obj|
        obj.value = obj.value.gsub(/\s([a-zA-Z])?/) do
          $1.to_s.upcase
        end
      end
    end

    def replace_special_chars!
      self.tap do |obj|
        obj.value = obj.value.
          gsub(/[(\[:]/, "--").
          gsub(/[)\]'""]/, "").
          gsub(/[,\.\/&;]/, '-')
      end
    end

    def handle_numbers_at_beginning!
      self.tap do |obj|
        obj.value = obj.value.gsub(/^[0-9].*$/) do |match|
          "_#{match}"
        end
      end
    end

    # TODO This should move to umt because it absolutely makes no sense here
    def sanitize_for_base_form!
      self.tap do |obj|
        obj.value = obj.value.gsub(/[,\/\.\[\]]/, '')
      end
    end

  end
end

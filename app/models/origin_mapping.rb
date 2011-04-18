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

class OriginMapping

  def self.replace_umlauts(str)
    str.gsub(/Ö/, 'Oe').
    gsub(/Ä/, 'Ae').
    gsub(/Ü/, 'Ue').
    gsub(/ö/, 'oe').
    gsub(/ä/, 'ae').
    gsub(/ü/, 'ue').
    gsub(/ß/, 'ss')
  end

  def self.replace_whitespace(str)
    str.gsub(/\s/,'_').camelize
  end

  def self.replace_special_chars(str)
    str.gsub("[", "--").gsub("]", "").gsub("(", "--").gsub(")", "").gsub(',', '-').gsub('/', '-')
  end

  def self.sanitize_for_base_form(str)
    # str.gsub(/[,\/\.\[\]]/, '')
    str.gsub(",", "").gsub("/", "").gsub(".", "").gsub("[", "").gsub("]", "")
  end

  def self.merge(str)
    replace_umlauts(replace_whitespace(replace_special_chars(str)))
  end

end

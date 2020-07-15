# encoding: UTF-8

# Copyright 2011-2013 innoQ Deutschland GmbH
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

module FormHelper
  ## Generates verbose bootstrap wrapper HTML for generic forms
  #
  ## Accepts a hash of arguments with the following keys:
  ## id: id attribute of the input element (necessary for accessible labels)
  ## label: label text
  def input_block(options = {}, &block)
    label_text = options.delete(:label)
    id = options.delete(:id)

    label = if label_text
      label_tag(id, label_text, class: 'col-form-label')
    else
      ActiveSupport::SafeBuffer.new # empty safe string
    end

    content_tag(:div, class: 'control-group') do
      label <<
      content_tag(:div, class: 'controls') do
        capture(&block)
      end
    end
  end
end

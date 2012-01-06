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

module DashboardHelper

  def sorting_arrows_for(name)
    content_tag :div, :class => "sorting_arrows" do
      link_to(image_tag("arrow_down.gif", :class => "arrow_down"),
        dashboard_path(:order => "asc", :by => name.to_s)) +
        link_to(image_tag("arrow_up.gif", :class => "arrow_up"),
        dashboard_path(:order => "desc", :by => name.to_s))
    end
  end

  def consistency_status(item)
    css, msg = if item.valid_with_full_validation?
      ["valid", "&#x2713;"]
    else
      ["invalid", "&#x2717;"]
    end

    content_tag :span, raw(msg), :class => css
  end
  
  def link_to_dashboard_item(item)
    if item.is_a?(Label::Base) 
      item.published? ? label_path(:id => item.origin) : label_path(:published => 0, :id => item.origin)
    else
      item.published? ? concept_path(:id => item.origin) : concept_path(:published => 0, :id => item.origin)
    end
  end

end

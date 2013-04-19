# encoding: UTF-8

# Copyright 2013 innoQ Deutschland GmbH
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

module Concept
  module TypedHasManyExtension

    def for_class(klass)
      load_target.select{|assoc| assoc.type.to_s == klass.to_s}
    end

    def for_rdf_class(rdf_class)
      load_target.select{|assoc| assoc.implements_rdf? rdf_class}
    end

    def destroy_later(obj)
      proxy_association.owner.send :mark_for_destruction, obj
      load_target.delete(obj)
    end

  end
end


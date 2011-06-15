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

class RdfStore
  # TODO This must be modularized and refactored and the thread should be
  # replaced by a direct rack call or usage of helpers
  #
  # * Modulization: The RdfStore should be more abstract. A special adapter
  #   (e.g. for virtuoso or sesame) should be implemented in a extending
  #   class.
  # * No threads: throw out the JRuby stuff and replace it with:
  #     * Rack calls to the particluar action or
  #     * With the help of the RdfHelper#render_concept method

  include Java rescue nil
  include java.lang.Runnable rescue nil

  @@conn = nil

  def initialize(graph_uri, ttl_url, do_delete, ttl_content = nil)
    if Rails.application.config.virtuoso_jdbc_driver_url
      @graph_uri = graph_uri
      @ttl_url = ttl_url
      @ttl_content = ttl_content
      @do_delete = do_delete

      Rails.logger.info("** [RdfStore] Beginning virtuoso sync. Insert turtle into graph <#{@graph_uri}> from url: #{@ttl_url}; Clear graph first: #{@do_delete}.")

      unless @@conn
        # import "virtuoso.jdbc3.Driver"
        java.lang.Class.forName("virtuoso.jdbc3.Driver", true, JRuby.runtime.jruby_class_loader)
        @@conn = java.sql.DriverManager.getConnection(Rails.application.config.virtuoso_jdbc_driver_url)
        Rails.logger.debug("** [RdfStore] JDBC connection is up.")
      end

      if Rails.application.config.virtuoso_sync_threaded
        Rails.logger.debug("** [RdfStore] Starting sync thread.")
        java.lang.Thread.new(self).start
      else
        self.run
      end
    end
  end

  def self.insert(graph_uri, ttl_url)
    return false unless Rails.application.config.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, ttl_url, false)
    true
  end

  def self.update(graph_uri, ttl_url)
    return false unless Rails.application.config.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, ttl_url, true)
    true
  end

  def self.delete(graph_uri)
    return false unless Rails.application.config.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, nil, true)
    true
  end

  def self.mass_import(graph_uri, turtle_content)
    return false unless Rails.application.config.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, nil, true, turtle_content)
    true
  end

  def run
    if (@do_delete)
      Rails.logger.debug("** [RdfStore] Executing SPARQL DELETE.")
      @@conn.createStatement().execute("SPARQL CLEAR GRAPH <#{@graph_uri}>")
    end
    if (@ttl_url)
      Rails.logger.debug("** [RdfStore] Executing turtle load from url.")
      @@conn.createStatement().execute("DB.DBA.TTLP(HTTP_GET('#{@ttl_url}'), '', '#{@graph_uri}')")
    end
    if (@ttl_content)
      @@conn.createStatement().execute("DB.DBA.TTLP('#{@ttl_content.gsub("\\", "\\\\\\").gsub("'", "\\\\'")}', '', '#{@graph_uri}')")
    end
    Rails.logger.info("** [RdfStore] Virtuoso sync done.")
  end
end
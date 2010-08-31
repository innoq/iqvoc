class RdfStore

  include Java rescue nil
  include java.lang.Runnable rescue nil

  @@conn = nil

  def initialize(graph_uri, ttl_url, do_delete, ttl_content = nil)
    if configatron.virtuoso_jdbc_driver_url
      @graph_uri = graph_uri
      @ttl_url = ttl_url
      @ttl_content = ttl_content
      @do_delete = do_delete

      Rails.logger.info("** [RdfStore] Beginning virtuoso sync. Insert turtle into graph <#{@graph_uri}> from url: #{@ttl_url}; Clear graph first: #{@do_delete}.")

      unless @@conn
        # import "virtuoso.jdbc3.Driver"
        java.lang.Class.forName("virtuoso.jdbc3.Driver", true, JRuby.runtime.jruby_class_loader)
        @@conn = java.sql.DriverManager.getConnection(configatron.virtuoso_jdbc_driver_url)
        Rails.logger.debug("** [RdfStore] JDBC connection is up.")
      end

      if configatron.virtuoso_sync_threaded
        Rails.logger.debug("** [RdfStore] Starting sync thread.")
        java.lang.Thread.new(self).start
      else
        self.run
      end
    end
  end

  def self.insert(graph_uri, ttl_url)
    return false unless configatron.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, ttl_url, false)
    true
  end

  def self.update(graph_uri, ttl_url)
    return false unless configatron.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, ttl_url, true)
    true
  end

  def self.delete(graph_uri)
    return false unless configatron.virtuoso_jdbc_driver_url
    RdfStore.new(graph_uri, nil, true)
    true
  end
  
  def self.mass_import(graph_uri, turtle_content)
    return false unless configatron.virtuoso_jdbc_driver_url
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
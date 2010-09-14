class String

  def to_relation_name
    underscore.gsub("/", "_").pluralize
  end

end
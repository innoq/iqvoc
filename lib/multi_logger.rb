class MultiLogger

  attr_reader :loggers

  def initialize(*args)
    @loggers = args
  end

  def level=(level)
    @loggers.each { |logger| logger.level = level }
  end

  def levels
    @loggers.map(&:level)
  end

  def min_level
    levels.min
  end

  def close
    @loggers.map(&:close)
  end

  def add(level, *args)
    @loggers.each { |logger| logger.add(level, *args) }
  end

  Logger::Severity.constants.each do |level|
    define_method(level.downcase) do |*args|
      @loggers.each { |logger| logger.send(level.downcase, *args) }
    end

    define_method("#{ level.downcase }?".to_sym) do
      min_level <= Logger::Severity.const_get(level)
    end
  end
end

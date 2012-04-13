# encoding: UTF-8

# prints arguments to STDOUT or log depending on context
# optional block should return an array of values; the resulting output is then
# wrapped in separator lines
# the last argument may be an options hash with members :inspect and/or :tag
#
# examples:
#   dbg("IMPORTANT", foo, bar)
#   dbg { [lipsum] }
#   dbg(foo, bar, :inspect => false, :tag => false) do |args|
#      args << lorem
#      args << ipsum
#   end
def dbg(*args, &block)
  defaults = { :inspect => true, :tag => true }
  options = args.last.is_a?(Hash) && (defaults.keys & args.last.keys).any?
  options = defaults.merge(options ? args.pop : {})

  tty = defined?(Rails::Console) || Rails.env.test? # STDOUT is usually available here
  meth = tty ? method(:puts) : Rails.logger.method(:debug)

  if block
    meth.call "=" * 80
    block_args = yield [] # XXX: ideally we'd pass the `dbg` method itself here, but the need for `.call` makes for a weird API
    block_args << options
    dbg(*block_args)
    meth.call "-" * 80
    return unless args.length > 0
  end

  prefix = "#{args.shift} " if [String, Symbol].include?(args.first.class) # XXX: undocumented and unexpected

  serializer = options[:inspect] ? :inspect : :to_s
  msg = args.map(&serializer).join(" | ")
  msg = "#{prefix}#{msg}"
  msg = "[DEBUG] #{msg}" if options[:tag]

  meth.call msg
end

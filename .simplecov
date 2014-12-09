SimpleCov.configure do
  # ignore some files
  add_filter '/lib/tasks'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/test/'

  add_group 'Concerns', 'app/concerns'
end

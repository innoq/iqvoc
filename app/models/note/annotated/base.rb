class Note::Annotated::Base < ActiveRecord::Base # FIXME: Why isn't this Note::Annotation::Base? This looks like an annotaed note... but it is an annotation for a note right?

  set_table_name('note_annotations')

  belongs_to :note, :class_name => Note::Base.name

  # def value=(val)
  #   write_attribute(:value, IqvocGlobal::RdfHelper.quote_turtle_literal(val))
  # end

end

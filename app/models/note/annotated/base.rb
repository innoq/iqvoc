class Note::Annotated::Base < ActiveRecord::Base
  belongs_to :note, :class_name => Note::Base.name

  def value=(val)
    write_attribute(:value, IqvocGlobal::RdfHelper.quote_turtle_literal(val))
  end

end

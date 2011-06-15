class ChangeUmtNoteAnnotationsToDct < ActiveRecord::Migration
  def self.up
    Note::Annotated::Base.update_all({:namespace => "dct", :predicate => "creator"}, {:namespace => "umt", :predicate => "editor"})
  end

  def self.down
    Note::Annotated::Base.update_all({:namespace => "umt", :predicate => "editor"}, {:namespace => "dct", :predicate => "creator"})
  end
end

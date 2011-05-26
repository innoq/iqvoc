class SeparateNoteAnnotationPredicates < ActiveRecord::Migration
  def self.up
    rename_column :note_annotations, :identifier, :predicate
    add_column :note_annotations, :namespace, :string, :limit => 50

    total = Note::Annotated::Base.count
    i = 0

    puts "starting #{total} note annotation conversions..."
    reset = "\r" + "\e[0K" # adapted from http://snippets.dzone.com/posts/show/3760

    Note::Annotated::Base.find_each do |annotation|
      print "#{reset}#{i += 1} / #{total}"

      old_identifier = annotation.predicate
      namespace, predicate = old_identifier.split(":", 2)
      annotation.predicate = predicate
      annotation.namespace = namespace
      annotation.save!

      $stdout.flush
    end

    print "#{reset}"
    $stdout.flush
    puts "note annotation conversion complete"
  end

  def self.down
    Note::Annotated::Base.find_each do |annotation|
      identifier = [annotation.namespace, annotation.predicate].join(":")
      annotation.predicate = identifier
      annotation.save!
    end
    rename_column :note_annotations, :predicate, :identifier
    remove_column :note_annotations, :namespace
  end
end

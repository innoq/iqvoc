namespace :iqvoc do

  namespace :cleanup do

    desc 'adds explicit change notes positioning numbers'
    task :add_change_note_positions => :environment do
      change_notes = Iqvoc.change_note_class.joins(:annotations)
                  .where(note_annotations: { predicate: ['created', 'modified'] })
                  .order('note_annotations.value ASC')

      change_notes.group_by(&:owner).each do |_owner, notes| # slow for big collections
        notes.each_with_index do |note, i|
          note.update_column(:position, i.succ)
        end
      end
    end

    desc 'adds explicit notes positioning numbers to other note types'
    task :add_note_positions => :environment do
      note_types = Iqvoc::Concept.note_classes - [Iqvoc.change_note_class]

      note_types.each do |klass|
        puts "Migrating positions for #{klass}"
        notes = klass.where(position: nil).order(:id)

        notes.group_by(&:owner).each do |_owner, notes_for_owner| # slow for big collections
          notes_for_owner.each_with_index do |note, i|
            note.update_column(:position, i.succ)
          end
        end
      end
    end


  end

end

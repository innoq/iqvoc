class ChangeNotesValueCollation < ActiveRecord::Migration
  def up
    execute("ALTER TABLE notes MODIFY value varchar(4000) CHARACTER SET utf8 COLLATE utf8_bin;")
  end

  def down
    execute("ALTER TABLE notes MODIFY value varchar(4000) CHARACTER SET utf8 COLLATE utf8_general_ci;")
  end
end

class ExtendJobOutputLog < ActiveRecord::Migration
  def up
    change_column :exports, :output, :text, limit: 1_073_741_823
    change_column :imports, :output, :text, limit: 1_073_741_823
  end

  def down
    change_column :exports, :output, :text, limit: 65_535
    change_column :imports, :output, :text, limit: 65_535
  end
end

class ExtendJobOutputLog < ActiveRecord::Migration
  def up
    change_column :exports, :output, :text, limit: 4_294_967_295
    change_column :imports, :output, :text, limit: 4_294_967_295
  end

  def down
    change_column :exports, :output, :text, limit: 65_535
    change_column :imports, :output, :text, limit: 65_535
  end
end

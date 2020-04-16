class CreateImports < ActiveRecord::Migration[4.2]
  def change
    create_table :imports do |t|
      t.references :user
      t.text :output
      t.boolean :success, default: false
      t.timestamps
      t.timestamp :finished_at
    end
  end
end

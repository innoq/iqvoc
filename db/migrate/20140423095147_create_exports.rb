class CreateExports < ActiveRecord::Migration[4.2]
  def change
    create_table :exports do |t|
      t.references :user
      t.text :output
      t.boolean :success, default: false
      t.integer :file_type
      t.string :token
      t.timestamps
      t.timestamp :finished_at
    end
  end
end

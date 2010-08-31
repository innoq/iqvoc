class CreateClassifiers < ActiveRecord::Migration
  def self.up
    create_table :classifiers, :force => true do |t|
      t.string :title
      t.string :description
      t.string :notation
      t.timestamps
    end
  end

  def self.down
    drop_table :classifiers
  end
end

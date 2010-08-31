class CreateRoleMemberships < ActiveRecord::Migration
  def self.up
    create_table :role_memberships do |t|
      t.references :user
      t.references :role

      t.timestamps
    end
    
    add_index :role_memberships, :user_id
    add_index :role_memberships, :role_id
    add_index :role_memberships, [:user_id, :role_id]
  end

  def self.down
    drop_table :role_memberships
  end
end

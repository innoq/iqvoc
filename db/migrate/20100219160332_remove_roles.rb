class RemoveRoles < ActiveRecord::Migration
  def self.up
    drop_table :roles
    drop_table :role_memberships
  end

  def self.down
  end
end

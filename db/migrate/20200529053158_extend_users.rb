class ExtendUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :comment, :text

    # See https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/session/base.rb#L162
    add_column :users, :login_count, :integer, default: 0, null: false
    add_column :users, :failed_login_count, :integer, default: 0, null: false
    add_column :users, :last_request_at, :datetime
    add_column :users, :current_login_at, :datetime
    add_column :users, :last_login_at, :datetime
    add_column :users, :current_login_ip, :string
    add_column :users, :last_login_ip, :string
  end
end

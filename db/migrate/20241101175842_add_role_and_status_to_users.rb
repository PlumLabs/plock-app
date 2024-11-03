class AddRoleAndStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      t.string :role, default: "member"
      t.datetime :inactive_at
    end
  end
end

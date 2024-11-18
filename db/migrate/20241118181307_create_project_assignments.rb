class CreateProjectAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :project_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.string :role, null: false, default: "member"

      t.timestamps
    end

    add_index :project_assignments, [ :user_id, :project_id ], unique: true
  end
end

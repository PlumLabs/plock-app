class CreateTimeEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :time_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, foreign_key: true
      t.date :date, null: false
      t.integer :duration_minutes, default: 0, null: false
      t.text :description

      t.timestamps
    end
  end
end

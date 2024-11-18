class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.references :client, foreign_key: true
      t.datetime :disabled_at

      t.timestamps
    end
  end
end

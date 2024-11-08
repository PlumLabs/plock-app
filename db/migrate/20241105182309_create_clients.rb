class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, index: true
      t.string :email
      t.text :note
      t.datetime :disabled_at

      t.timestamps
    end
  end
end

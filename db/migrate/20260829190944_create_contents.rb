class CreateContents < ActiveRecord::Migration[8.1]
  def change
    create_table :contents do |t|
      t.references :link, foreign_key: true
      t.references :game, foreign_key: true
      t.references :contentable, polymorphic: true, null: false

      t.timestamps
    end
  end
end

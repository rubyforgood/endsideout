class CreateContents < ActiveRecord::Migration[8.1]
  def change
    create_table :contents do |t|
      t.references :content_module, foreign_key: true
      t.references :contentable, polymorphic: true, null: false, index: true

      t.timestamps
    end
  end
end

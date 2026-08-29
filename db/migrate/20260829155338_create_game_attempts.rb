class CreateGameAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :game_attempts do |t|
      t.integer :score
      t.string :outcome
      t.timestamp :started_at
      t.timestamp :finished_at
      t.references :student, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end

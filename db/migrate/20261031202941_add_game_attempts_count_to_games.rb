class AddGameAttemptsCountToGames < ActiveRecord::Migration[8.1]
  def change
    add_column :games, :game_attempts_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE games SET game_attempts_count =
            (SELECT COUNT(*) FROM game_attempts WHERE game_attempts.game_id = games.id)
        SQL
      end
    end
  end
end

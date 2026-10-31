module Admin::GamesHelper
  def delete_game_confirmation(game)
    module_count = game.contents.size
    return "Delete this game?" if module_count.zero?

    "Delete this game? It will be removed from #{pluralize(module_count, "module")}."
  end
end

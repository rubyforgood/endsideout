module Admin::GamesHelper
  def delete_game_confirmation(game)
    module_count = game.content_modules.size
    attempt_count = game.game_attempts.size

    consequences = []
    consequences << "It will be removed from #{pluralize(module_count, "module")}" if module_count.positive?
    consequences << "#{pluralize(attempt_count, "student attempt")} will be deleted" if attempt_count.positive?
    return "Delete this game?" if consequences.empty?

    "Delete this game? #{consequences.join(" and ")}."
  end
end

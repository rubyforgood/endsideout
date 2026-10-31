class Admin::Contents::PositionsController < AdminController
  def update
    content = Content.find(params.expect(:content_id))

    case params.expect(:direction)
    when "up" then content.move_up
    when "down" then content.move_down
    else return head :unprocessable_entity
    end

    redirect_to edit_admin_content_module_path(content.content_module), status: :see_other
  end
end

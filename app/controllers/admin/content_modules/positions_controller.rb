class Admin::ContentModules::PositionsController < AdminController
  def update
    content_module = ContentModule.find(params.expect(:content_module_id))

    case params.expect(:direction)
    when "up" then content_module.move_up
    when "down" then content_module.move_down
    else return head :unprocessable_entity
    end

    redirect_to admin_content_modules_path(program_id: content_module.program_id), status: :see_other
  end
end

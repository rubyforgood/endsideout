class Admin::ContentModules::PositionsController < AdminController
  def update
    direction = params.expect(:direction).to_sym
    return head :unprocessable_entity unless Ordered::DIRECTIONS.include?(direction)

    content_module = ContentModule.find(params.expect(:content_module_id))
    content_module.move(direction)

    redirect_to admin_content_modules_path(program_id: content_module.program_id), status: :see_other
  end
end

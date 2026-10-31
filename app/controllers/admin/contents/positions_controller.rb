class Admin::Contents::PositionsController < AdminController
  def update
    direction = params.expect(:direction)
    return head :unprocessable_entity unless Ordered::DIRECTIONS.include?(direction)

    content = Content.find(params.expect(:content_id))
    content.move(direction)

    redirect_to edit_admin_content_module_path(content.content_module), status: :see_other
  end
end

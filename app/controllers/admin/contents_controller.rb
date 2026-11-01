class Admin::ContentsController < AdminController
  before_action :set_content, only: %i[destroy]

  def destroy
    @content.destroy!
    redirect_to edit_admin_content_module_path(@content.content_module), notice: "Content was successfully removed.", status: :see_other
  end

  private
    def set_content
      @content = Content.find(params.expect(:id))
    end
end

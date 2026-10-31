class Admin::ContentsController < AdminController
  before_action :set_content_module, only: %i[create]
  before_action :set_content, only: %i[destroy]

  def create
    game = Game.find(params.expect(content: [ :contentable_id ]).fetch(:contentable_id))
    content = @content_module.contents.build(contentable: game)

    if content.save
      redirect_to edit_admin_content_module_path(@content_module), notice: "Game was successfully added."
    else
      redirect_to edit_admin_content_module_path(@content_module), alert: content.errors.full_messages.to_sentence
    end
  end

  def destroy
    @content.destroy!
    redirect_to edit_admin_content_module_path(@content.content_module), notice: "Content was successfully removed.", status: :see_other
  end

  private
    def set_content_module
      @content_module = ContentModule.find(params.expect(:content_module_id))
    end

    def set_content
      @content = Content.find(params.expect(:id))
    end
end

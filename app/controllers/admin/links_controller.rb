class Admin::LinksController < AdminController
  before_action :set_content_module, only: %i[new create]
  before_action :set_link, only: %i[edit update destroy]

  def new
    @link = Link.new
  end

  def create
    @link = Link.new(link_params)

    @link.build_content(content_module: @content_module)

    if @link.save
      redirect_to edit_admin_content_module_path(@content_module), notice: "Link was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @link.update(link_params)
      redirect_to edit_admin_content_module_path(@link.content_module), notice: "Link was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    content_module = @link.content_module
    @link.destroy!
    redirect_to edit_admin_content_module_path(content_module), notice: "Link was successfully deleted.", status: :see_other
  end

  private
    def set_content_module
      @content_module = ContentModule.find(params.expect(:content_module_id))
    end

    def set_link
      @link = Link.find(params.expect(:id))
    end

    def link_params
      params.expect(link: [ :title, :url, :link_type ])
    end
end

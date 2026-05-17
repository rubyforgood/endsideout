class ClassroomsController < AdminController
  before_action :set_classroom, only: %i[ edit update ]

  def edit
    build_missing_program_enrollments
  end

  def update
    respond_to do |format|
      if @classroom.update(classroom_params)
        format.html { redirect_to school_students_url(@classroom.school), notice: "Classroom was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @classroom }
      else
        build_missing_program_enrollments
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @classroom.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_classroom
      @classroom = Classroom.find(params.expect(:id))
    end

    def build_missing_program_enrollments
      existing = @classroom.classroom_programs.includes(:program).index_by(&:program_id)
      Program.order(:name).each do |program|
        existing[program.id] || @classroom.classroom_programs.build(program: program)
      end
    end

    def classroom_params
      params.expect(classroom: [ :name, :teacher, classroom_programs_attributes: [[ :id, :program_id, :level, :_destroy ]] ])
    end
end

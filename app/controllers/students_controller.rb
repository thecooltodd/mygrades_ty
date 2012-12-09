class StudentsController < ApplicationController
  # GET /students
  # GET /students.json
	
	helper_method :homework_weight
	before_filter :get_homework_earned
	
	def get_homework_earned
		@homework_earned = session[:h_earned]
	end
	
	def homework_weight
		@h_weight = Category.find_by_id(1).weight
	end
  
	def index
    @students = Student.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @students }
    end
  end
	
  # GET /students/1
  # GET /students/1.json
  def show
    @student = Student.find(params[:id])
		@course = Course.find(@student.course_id)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/new
  # GET /students/new.json
  def new
    @student = Student.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @student }
    end
  end

  # GET /students/1/edit
  def edit
    @student = Student.find(params[:id])
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(params[:student])

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render json: @student, status: :created, location: @student }
      else
        format.html { render action: "new" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /students/1
  # PUT /students/1.json
  def update
    @student = Student.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student = Student.find(params[:id])
    @student.destroy

    respond_to do |format|
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  def cutoff
    @resultavg = 0
    @resultstd = 0
    @students = Student.all
    @plusminus = params[:plus_minus]
    @acut = params[:Acut].to_f
    @bcut = params[:Bcut].to_f
    @ccut = params[:Ccut].to_f
    @dcut = params[:Dcut].to_f
    @flag = 1
    @students.each do |student|
      @c_total = 0
      @c_earned = 0
      Grade.find_all_by_student_id(student.id).each do |grade|
        Task.find_all_by_id(grade.task_id).each do |course|
          @c_total += course.total
          @c_earned += grade.earned
        end
      end
      student.total_score = (@c_earned.to_f/@c_total.to_f)*100
    end
    @students.each do |student|
    if @plusminus == "1"
        case
          when student.total_score >= (100-@acut)*2/3+@acut
            student.final_grade = "A+".html_safe
          when student.total_score >= (100-@acut)*1/3+@acut
            student.final_grade = "A".html_safe
          when student.total_score >= @acut
            student.final_grade = "A-".html_safe
          when student.total_score >= (@acut-@bcut)*2/3+@bcut
            student.final_grade = "B+".html_safe
          when student.total_score >= (@acut-@bcut)*1/3+@bcut
            student.final_grade = "B".html_safe
          when student.total_score >= @bcut
            student.final_grade = "B-".html_safe
          when student.total_score >= (@bcut-@ccut)*2/3+@ccut
            student.final_grade = "C+".html_safe
          when student.total_score >= (@bcut-@ccut)*1/3+@ccut
            student.final_grade = "C".html_safe
          when student.total_score >= @ccut
            student.final_grade = "C-".html_safe
          when student.total_score >= (@ccut-@dcut)*2/3+@dcut
            student.final_grade = "D+".html_safe
          when student.total_score >= (@ccut-@dcut)*1/3+@dcut
            student.final_grade = "D".html_safe
          when student.total_score >= @dcut
            student.final_grade = "D-".html_safe
          when student.total_score >= 0
            student.final_grade = "F".html_safe
        end
      else
        case
          when student.total_score >= @acut
            student.final_grade = "A".html_safe
          when student.total_score >= @bcut
            student.final_grade = "B".html_safe
          when student.total_score >= @ccut
            student.final_grade = "C".html_safe
          when student.total_score >= @dcut
            student.final_grade = "D".html_safe
          when student.total_score >= 0
            student.final_grade = "F".html_safe
        end
      end
    end
    render "calculate"
  end

  def custom
    render "custom"
  end

  def choice_render
    render "choices"
  end

  def selectchoice
    @plusminus = params[:plusminus]
    @selection = params[:selection]
    if @selection == "custom"
      render "custom"
    else
      @test = "WAT"
      @flag = 0
      @students = Student.all
      @students.each do |student|
        @c_total = 0
        @c_earned = 0
        Grade.find_all_by_student_id(student.id).each do |grade|
          Task.find_all_by_id(grade.task_id).each do |course|
            @c_total += course.total
            @c_earned += grade.earned
          end
        end
        student.total_score = (@c_earned.to_f/@c_total.to_f)*100
      end
      @resultavg = @students.inject(0){|acc, student| acc + student.total_score}/@students.length.to_f
      @resultstd = Math.sqrt(@students.inject(0){|sum, u|sum+(u.total_score-@resultavg)**2}/@students.length.to_f)
      @students.each do |student|
        if @plusminus == "1"
          case 
          when student.total_score >= ((100-@resultavg+1.5*@resultstd)*2/3+@resultavg+1.5*@resultstd)
            student.final_grade = "A+".html_safe
          when student.total_score >= ((100-@resultavg+1.5*@resultstd)*1/3+@resultavg+1.5*@resultstd)
            student.final_grade = "A".html_safe
          when student.total_score >= (@resultavg+1.5*@resultstd)
            student.final_grade = "A-".html_safe
          when student.total_score >= ((@resultavg+1.5*@resultstd-@resultavg+0.5*@resultstd)*2/3+@resultavg+0.5*@resultstd)
            student.final_grade = "B+".html_safe
          when student.total_score >= ((@resultavg+1.5*@resultstd-@resultavg+0.5*@resultstd)*1/3+@resultavg+0.5*@resultstd)
            student.final_grade = "B".html_safe
          when student.total_score >= (@resultavg+0.5*@resultstd)
            student.final_grade = "B-".html_safe
          when student.total_score >= ((@resultstd)*2/3+@resultavg-0.5*@resultstd)
            student.final_grade = "C+".html_safe
          when student.total_score >= ((@resultstd)*1/3+@resultavg-0.5*@resultstd)
            student.final_grade = "C".html_safe
          when student.total_score >= (@resultavg-0.5*@resultstd)
            student.final_grade = "C-".html_safe
          when student.total_score >= ((@resultavg-0.5*@resultstd-@resultavg-1.5*@resultstd)*2/3+@resultavg-1.5*@resultstd)
            student.final_grade = "D+".html_safe
          when student.total_score >= ((@resultavg-0.5*@resultstd-@resultavg-1.5*@resultstd)*1/3+@resultavg-1.5*@resultstd)
            student.final_grade = "D".html_safe
          when student.total_score >= (@resultavg-1.5*@resultstd)
            student.final_grade = "D-".html_safe
          when student.total_score >= 0
            student.final_grade = "F".html_safe
          end
        else
          case student.total_score when (@resultavg-0.5*@resultstd)..(@resultavg+0.5*@resultstd)
            student.final_grade = "C".html_safe
          when (@resultavg+0.5*@resultstd)..(@resultavg+1.5*@resultstd)
            student.final_grade = "B".html_safe
          when (@resultavg+1.5*@resultstd)..150 
            student.final_grade = "A".html_safe
          when (@resultavg-1.5*@resultstd)..(@resultavg-0.5*@resultstd)
            student.final_grade = "D".html_safe
          when 0..(@resultavg-1.5*@resultstd)
            student.final_grade = "F".html_safe
          end
        end
      end
      render "calculate"
    end
  end
end

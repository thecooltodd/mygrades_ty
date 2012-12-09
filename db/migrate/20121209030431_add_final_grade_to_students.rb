class AddFinalGradeToStudents < ActiveRecord::Migration
  def change
    add_column :students, :final_grade, :string
  end
end

class AddCourseTotalToStudents < ActiveRecord::Migration
  def change
    add_column :students, :total_score, :decimal
  end
end

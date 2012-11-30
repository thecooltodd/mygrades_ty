class AddTotalscoreToTable < ActiveRecord::Migration
  def change
    add_column :tables, :total_score, :decimal
  end
end

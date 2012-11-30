class AddFieldnameIdToTablename < ActiveRecord::Migration
  def change
    add_column :tablenames, :total_score, :decimal
  end
end

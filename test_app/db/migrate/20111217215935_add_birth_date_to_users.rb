class AddBirthDateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :birth_date, :datetime
  end
end

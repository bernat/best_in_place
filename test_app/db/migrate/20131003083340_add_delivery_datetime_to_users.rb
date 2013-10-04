class AddDeliveryDatetimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :delivery, :datetime
  end
end

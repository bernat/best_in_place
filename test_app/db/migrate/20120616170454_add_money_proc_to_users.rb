class AddMoneyProcToUsers < ActiveRecord::Migration
  def change
    add_column :users, :money_proc, :float

  end
end

class AddHeightToUser < ActiveRecord::Migration
  def change
    add_column :users, :height, :string
  end
end

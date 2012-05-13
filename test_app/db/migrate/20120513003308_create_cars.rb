class CreateCars < ActiveRecord::Migration
  def up
    create_table :cars do |t|
      t.string :model
    end
  end

  def down
    drop_table :cars
  end
end

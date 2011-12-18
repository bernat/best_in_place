class AddAvatarToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
     
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      
    end
  end

  def self.down
    change_table :users do |t|

      t.remove :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at
      end

  end
end

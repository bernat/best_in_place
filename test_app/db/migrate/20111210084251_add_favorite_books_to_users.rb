class AddFavoriteBooksToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favorite_books, :text
  end
end

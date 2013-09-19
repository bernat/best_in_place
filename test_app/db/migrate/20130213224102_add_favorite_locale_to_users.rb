class AddFavoriteLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :favorite_locale, :string
  end
end

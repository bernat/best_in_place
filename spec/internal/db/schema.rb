ActiveRecord::Schema.define do
  create_table "cars", :force => true do |t|
    t.string "model"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "last_name"
    t.string   "address"
    t.string   "email",           :null => false
    t.string   "zip"
    t.string   "country"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.boolean  "receive_email"
    t.text     "description"
    t.string   "favorite_color"
    t.text     "favorite_books"
    t.datetime "birth_date"
    t.float    "money"
    t.float    "money_proc"
    t.string   "height"
    t.string   "favorite_movie"
    t.string   "favorite_locale"
    t.integer  "zero_field"
  end

  create_table "test_results", :force => true do |t|
    t.string   "name"
    t.string   "result"
    t.integer  "user_id"
  end
end

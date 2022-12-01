# encoding: utf-8

describe "JS behaviour", :js => true do
  before do
    @user = User.new :name => "Lucia",
      :last_name => "Napoli",
      :email => "lucianapoli@gmail.com",
      :height => "5' 5\"",
      :address => "Via Roma 99",
      :zip => "25123",
      :country => "2",
      :receive_email => false,
      :description => "User description"
  end

  it "should be able to use bip_text to update a text area" do
    @user.save!
    visit user_path(@user)
    expect(page.find('#description')).to have_content('User description')

    bip_area @user, :description, "A new description"

    visit user_path(@user)
    expect(page.find('#description')).to have_content('A new description')
  end

  it "should be able to use a bip_text with :display_with option" do
    @user.description = "I'm so awesome"
    @user.save!
    visit user_path(@user)

    expect(find('#dw_description')).to have_content("I'm so awesome")
  end
end

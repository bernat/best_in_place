# encoding: utf-8
require "spec_helper"

describe "Double initialization bug", :js => true do
  before do
    @user = User.new :name => "Lucia",
      :last_name => "Napoli",
      :email => "lucianapoli@gmail.com",
      :height => "5' 5\"",
      :address => "Via Roma 99",
      :zip => "25123",
      :country => "2",
      :receive_email => false,
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
      :money => 100
  end

  it "should be able to change a boolean value" do
    @user.save!
    visit double_init_user_path(@user)

    within("#receive_email") do
      page.should have_content("No thanks")
    end

    bip_bool @user, :receive_email

    visit double_init_user_path(@user)
    within("#receive_email") do
      page.should have_content("Yes of course")
    end

  end
end

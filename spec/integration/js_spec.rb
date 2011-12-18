# encoding: utf-8
require "spec_helper"

describe "JS behaviour", :js => true do
  before do
    @user = User.new :name => "Lucia",
      :last_name => "Napoli",
      :email => "lucianapoli@gmail.com",
      :address => "Via Roma 99",
      :zip => "25123",
      :country => "2",
      :receive_email => false,
      :favorite_color => 'Red',
      :favorite_books => "The City of Gold and Lead",
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem."
  end

  describe "nil option" do
    it "should render the default '-' string when the field is empty" do
      @user.name = ""
      @user.save :validate => false
      visit user_path(@user)

      within("#name") do
        page.should have_content("-")
      end
    end

    it "should render the passed nil value if the field is empty" do
      @user.last_name = ""
      @user.save :validate => false
      visit user_path(@user)

      within("#last_name") do
        page.should have_content("Nothing to show")
      end
    end
  end

  it "should be able to use bip_text to update a text field" do
    @user.save!
    visit user_path(@user)
    within("#email") do
      page.should have_content("lucianapoli@gmail.com")
    end

    bip_text @user, :email, "new@email.com"

    visit user_path(@user)
    within("#email") do
      page.should have_content("new@email.com")
    end
  end

  it "should be able to update a field two consecutive times" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :email, "new@email.com"

    within("#email") do
      page.should have_content("new@email.com")
    end

    bip_text @user, :email, "new_two@email.com"

    within("#email") do
      page.should have_content("new_two@email.com")
    end

    visit user_path(@user)
    within("#email") do
      page.should have_content("new_two@email.com")
    end
  end

  it "should be able to update a field after an error" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :email, "wrong format"
    page.should have_content("Email has wrong email format")

    bip_text @user, :email, "another@email.com"
    within("#email") do
      page.should have_content("another@email.com")
    end

    visit user_path(@user)
    within("#email") do
      page.should have_content("another@email.com")
    end
  end

  it "should be able to use bip_select to change a select field" do
    @user.save!
    visit user_path(@user)
    within("#country") do
      page.should have_content("Italy")
    end

    bip_select @user, :country, "France"

    visit user_path(@user)
    within("#country") do
      page.should have_content("France")
    end
  end

  it "should be able to use bip_bool to change a boolean value" do
    @user.save!
    visit user_path(@user)

    within("#receive_email") do
      page.should have_content("No thanks")
    end

    bip_bool @user, :receive_email

    visit user_path(@user)
    within("#receive_email") do
      page.should have_content("Yes of course")
    end
  end

  it "should correctly use an OK submit button when so configured for a text field" do
    @user.save!
    visit user_path(@user)

    within("#favorite_color") do
      page.should have_content('Red')
    end
    
    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_color']").val('Blue');
      $("##{id} input[type='submit']").click();
    JS
    
    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Blue')
    end
  end
  
  it "should correctly use a Cancel button when so configured for a text field" do
    @user.save!
    visit user_path(@user)

    within("#favorite_color") do
      page.should have_content('Red')
    end
    
    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_color']").val('Blue');
      $("##{id} input[type='button']").click();
    JS

    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Red')
    end
  end
  
  it "should correctly use an OK submit button when so configured for a text area" do
    @user.save!
    visit user_path(@user)

    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end
    
    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} textarea").val('1Q84');
      $("##{id} input[type='submit']").click();
    JS

    visit user_path(@user)
    within("#favorite_books") do
      page.should have_content('1Q84')
    end
  end
  
  it "should correctly use a Cancel button when so configured for a text area" do
    @user.save!
    visit user_path(@user)

    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end
    
    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} textarea").val('1Q84');
      $("##{id} input[type='button']").click();
    JS
    
    visit user_path(@user)
    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end
  end
  
  it "should show validation errors" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :address, ""
    page.should have_content("Address can't be blank")
    within("#address") do
      page.should have_content("Via Roma 99")
    end
  end

  it "should show validation errors using respond_with in the controller" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :last_name, "a"
    page.should have_content("last_name has invalid length")
  end

  it "should be able to update a field after an error using respond_with in the controller" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :last_name, "a"

    within("#last_name") do
      page.should have_content("Napoli")
    end

    bip_text @user, :last_name, "Another"

    within("#last_name") do
      page.should have_content("Another")
    end

    visit user_path(@user)
    within("#last_name") do
      page.should have_content("Another")
    end
  end

  it "should fire off a callback when updating a field" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
    page.execute_script <<-JS
      $("##{id}").bind('best_in_place:update', function() { $('body').append('Last name was updated!') });
    JS

    page.should have_no_content('Last name was updated!')
    bip_text @user, :last_name, 'Another'
    page.should have_content('Last name was updated!')
  end

  describe "display_as" do
    it "should render the address with a custom format" do
      @user.save!
      visit user_path(@user)

      within("#address") do
        page.should have_content("addr => [Via Roma 99]")
      end
    end

    it "should still show the custom format after an error" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :address, "inva"

      within("#address") do
        page.should have_content("addr => [Via Roma 99]")
      end
    end

    it "should show the new result with the custom format after an update" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :address, "New address"

      within("#address") do
        page.should have_content("addr => [New address]")
      end
    end

    it "should display the original content when editing the form" do
      @user.save!
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :address
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} input").value
      text.should == "Via Roma 99"
    end

    it "should display the updated content after editing the field two consecutive times" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :address, "New address"

      id = BestInPlace::Utils.build_best_in_place_id @user, :address
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} input").value
      text.should == "New address"
    end
  end
end


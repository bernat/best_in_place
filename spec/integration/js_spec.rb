# encoding: utf-8
require "spec_helper"

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
      :birth_date => Time.now.utc,
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
      :money => 100,
      :money_proc => 100,
      :favorite_color => 'Red',
      :favorite_books => "The City of Gold and Lead",
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
      :favorite_movie => "The Hitchhiker's Guide to the Galaxy"
  end

  describe "namespaced controllers" do
    it "should be able to use array-notation to describe both object and path" do
      @user.save!
      visit admin_user_path(@user)

      within("#last_name") { page.should have_content("Napoli") }
      bip_text @user, :last_name, "Other thing"

      within("#last_name") { page.should have_content("Other thing") }
    end
  end

  describe "nil option" do
    it "should render an em-dash when the field is empty" do
      @user.name = ""
      @user.save :validate => false
      visit user_path(@user)

      within("#name") do
        page.should have_content("\u2014")
      end
    end

    it "should render the default em-dash string when there is an error and if the intial string is em-dash" do
      @user.money = nil
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "abcd"

      within("#money") do
        page.should have_content("\u2014")
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

    it "should render html content for nil option" do
      @user.favorite_color = ""
      @user.save!
      visit user_path(@user)
      within("#favorite_color") do
        page.should have_xpath("//span[@class='nil']")
      end
    end

    it "should render html content for nil option after edit" do
      @user.favorite_color = "Blue"
      @user.save!
      visit user_path(@user)

      bip_text @user, :favorite_color, ""

      within("#favorite_color") do
        page.should have_xpath("//span[@class='nil']")
      end
    end

    it "should display an empty input field the second time I open it" do
      @user.favorite_locale = nil
      @user.save!
      visit user_path(@user)

      within("#favorite_locale") do
        page.should have_content("N/A")
      end

      id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_locale
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} input").value
      text.should == ""

      page.execute_script <<-JS
        $("##{id} input[name='favorite_locale']").blur();
        $("##{id} input[name='favorite_locale']").blur();
      JS
      sleep 1

      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} input").value
      text.should == ""
    end
  end

  it "should be able to update last but one item in list" do
    @user.save!
    @user2 = User.create :name => "Test",
      :last_name => "User",
      :email => "test@example.com",
      :height => "5' 5\"",
      :address => "Via Roma 99",
      :zip => "25123",
      :country => "2",
      :receive_email => false,
      :birth_date => Time.now.utc,
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
      :money => 100,
      :money_proc => 100,
      :favorite_color => 'Red',
      :favorite_books => "The City of Gold and Lead",
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem."

    visit users_path

    within("tr#user_#{@user.id} > .name > span") do
      page.should have_content("Lucia")
      page.should have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :name
    page.execute_script <<-JS
      $("#edit_#{@user.id}").click();
      $("##{id} input[name='name']").val('Lisa');
      $("##{id} form").submit();
    JS

    within("tr#user_#{@user.id} > .name > span") do
      page.should have_content('Lisa')
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

  it "should apply the inner_class option to a select field" do
    @user.save!
    visit user_path(@user)

    find('#country span').click
    find('#country').should have_css('select.some_class')
  end

  it "should be able to use bip_text to change a date field" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)
    within("#birth_date") do
      page.should have_content(today)
    end

    bip_text @user, :birth_date, (today - 1.days)

    visit user_path(@user)
    within("#birth_date") do
      page.should have_content(today - 1.days)
    end
  end

  it "should be able to use datepicker to change a date field" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)
    within("#birth_date") do
      page.should have_content(today)
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :birth_date
    page.execute_script <<-JS
      $("##{id}").click()
      $(".ui-datepicker-calendar tbody td").not(".ui-datepicker-other-month").first().click()
    JS

    visit user_path(@user)
    within("#birth_date") do
      page.should have_content(today.beginning_of_month)
    end
  end

  it "should be able to modify the datepicker options, displaying the date with another format" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)
    within("#birth_date") do
      page.should have_content(today)
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :birth_date
    page.execute_script <<-JS
      $("##{id}").click()
      $(".ui-datepicker-calendar tbody td").not(".ui-datepicker-other-month").first().click()
    JS

    within("#birth_date") do
      page.should have_content(today.beginning_of_month.strftime("%d-%m-%Y"))
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

  it "should be able to use bip_bool to change a boolean value using an image" do
    @user.save!
    visit user_path(@user)

    within("#receive_email_image") do
      page.should have_xpath("//img[contains(@src,'no.png')]")
    end

    bip_bool @user, :receive_email

    visit user_path(@user)
    within("#receive_email_image") do
      page.should have_xpath("//img[contains(@src,'yes.png')]")
    end
  end

  it "should correctly use an OK submit button when so configured for an input" do
    @user.save!
    visit user_path(@user)

    within("#favorite_color") do
      page.should have_content('Red')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_color']").val('Blue');
    JS

    page.find("##{id} input[type='submit']").value.should == 'Do it!'
    page.should have_css("##{id} input[type='submit'].custom-submit.other-custom-submit")

    page.execute_script <<-JS
      $("##{id} input[type='submit']").click();
    JS

    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Blue')
    end
  end

  it "should correctly use a Cancel button when so configured for an input" do
    @user.save!
    visit user_path(@user)

    within("#favorite_color") do
      page.should have_content('Red')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_color']").val('Blue');
    JS

    page.find("##{id} input[type='button']").value.should == 'Nope'
    page.should have_css("##{id} input[type='button'].custom-cancel.other-custom-cancel")

    page.execute_script <<-JS
      $("##{id} input[type='button']").click();
    JS

    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Red')
    end
  end

  it "should not ask for confirmation on cancel if it is switched off" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_movie
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_movie']").val('No good movie');
      $("##{id} input[type='button']").click();
    JS

    lambda { page.driver.browser.switch_to.alert }.should raise_exception(Selenium::WebDriver::Error::NoAlertPresentError)
    within("#favorite_movie") do
      page.should have_content("The Hitchhiker's Guide to the Galaxy")
    end
  end

  it "should not submit input on blur if there's an OK button present" do
    @user.save!
    visit user_path(@user)

    within("#favorite_color") do
      page.should have_content('Red')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} input[name='favorite_color']").val('Blue');
      $("##{id} input[name='favorite_color']").blur();
    JS
    sleep 1 # Increase if browser is slow

    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Red')
    end
  end

  it "should still submit input on blur if there's only a Cancel button present" do
    @user.save!
    visit user_path(@user, :suppress_ok_button => 1)

    within("#favorite_color") do
      page.should have_content('Red')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    page.execute_script %{$("##{id}").click();}
    page.should have_no_css("##{id} input[type='submit']")
    page.execute_script <<-JS
      $("##{id} input[name='favorite_color']").val('Blue');
      $("##{id} input[name='favorite_color']").blur();
      $("##{id} input[name='favorite_color']").blur();
    JS
    sleep 1 # Increase if browser is slow

    visit user_path(@user)
    within("#favorite_color") do
      page.should have_content('Blue')
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
    page.driver.browser.switch_to.alert.accept

    visit user_path(@user)
    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end
  end

  it "should not submit text area on blur if there's an OK button present" do
    @user.save!
    visit user_path(@user)

    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    page.execute_script <<-JS
      $("##{id}").click();
      $("##{id} textarea").val('1Q84');
      $("##{id} textarea").blur();
      $("##{id} textarea").blur();
    JS
    sleep 1 # Increase if browser is slow
    page.driver.browser.switch_to.alert.accept

    visit user_path(@user)
    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end
  end

  it "should still submit text area on blur if there's only a Cancel button present" do
    @user.save!
    visit user_path(@user, :suppress_ok_button => 1)

    within("#favorite_books") do
      page.should have_content('The City of Gold and Lead')
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    page.execute_script %{$("##{id}").click();}
    page.should have_no_css("##{id} input[type='submit']")
    page.execute_script <<-JS
      $("##{id} textarea").val('1Q84');
      $("##{id} textarea").blur();
      $("##{id} textarea").blur();
    JS
    sleep 1 # Increase if browser is slow

    visit user_path(@user)
    within("#favorite_books") do
      page.should have_content('1Q84')
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

  it "should fire off a callback when retrieve success with empty data" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
    page.execute_script <<-JS
      $("##{id}").bind('best_in_place:success', function() { $('body').append('Updated successfully!') });
    JS

    page.should have_no_content('Updated successfully!')
    bip_text @user, :last_name, 'Empty'
    page.should have_content('Updated successfully!')
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
      retry_on_timeout do
        visit user_path(@user)

        id = BestInPlace::Utils.build_best_in_place_id @user, :address
        page.execute_script <<-JS
          $("##{id}").click();
        JS

        text = page.find("##{id} input").value
        text.should == "Via Roma 99"
      end
    end

    it "should display the updated content after editing the field two consecutive times" do
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        bip_text @user, :address, "New address"

        sleep 1

        id = BestInPlace::Utils.build_best_in_place_id @user, :address
        page.execute_script <<-JS
          $("##{id}").click();
        JS

        sleep 1

        text = page.find("##{id} input").value
        text.should == "New address"
      end
    end

    it "should quote properly the data-original-content attribute" do
      @user.address = "A's & B's"
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        id = BestInPlace::Utils.build_best_in_place_id @user, :address

        text = page.find("##{id}")["data-original-content"]
        text.should == "A's & B's"
      end
    end
  end

  describe "display_with" do
    it "should show nil text when original value is nil" do
      @user.description = ""
      @user.save!

      visit user_path(@user)

      within("#dw_description") { page.should have_content("\u2014") }
    end

    it "should render the money using number_to_currency" do
      @user.save!
      visit user_path(@user)

      within("#money") do
        page.should have_content("$100.00")
      end
    end

    it "should let me use custom helpers with a lambda" do
      @user.save!
      visit user_path(@user)

      page.should have_content("100.0 €")
      bip_text @user, :money_custom, "250"

      within("#money_custom") do
        page.should have_content("250.0 €")
      end
    end

    it "should still show the custom format after an error" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "string"

      page.should have_content("Money is not a number")

      within("#money") do
        page.should have_content("$100.00")
      end
    end

    it "should show the new value using the helper after a successful update" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "240"

      within("#money") do
        page.should have_content("$240.00")
      end
    end

    it "should display the original content when editing the form" do
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        id = BestInPlace::Utils.build_best_in_place_id @user, :money
        page.execute_script <<-JS
          $("##{id}").click();
        JS

        text = page.find("##{id} input").value
        text.should == "100.0"
      end
    end

    it "should display the updated content after editing the field two consecutive times" do
      @user.save!

      retry_on_timeout do
        visit user_path(@user)

        bip_text @user, :money, "40"

        sleep 1

        id = BestInPlace::Utils.build_best_in_place_id @user, :money
        page.execute_script <<-JS
          $("##{id}").click();
        JS

        sleep 1

        text = page.find("##{id} input").value
        text.should == "40"
      end
    end

    it "should show the money in euros" do
      @user.save!
      visit double_init_user_path(@user)

      within("#alt_money") { page.should have_content("€100.00") }

      bip_text @user, :money, 58

      within("#alt_money") { page.should have_content("€58.00") }
    end

    it "should keep link after edit with display_with :link_to" do
      @user.save!
      visit users_path
      within("tr#user_#{@user.id} > .name > span") do
        page.should have_content("Lucia")
        page.should have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
      id = BestInPlace::Utils.build_best_in_place_id @user, :name
      page.execute_script <<-JS
        jQuery("#edit_#{@user.id}").click();
        jQuery("##{id} input[name='name']").val('Maria Lucia');
        jQuery("##{id} form").submit();
      JS
      within("tr#user_#{@user.id} > .name > span") do
        page.should have_content("Maria Lucia")
        page.should have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
    end

    it "should keep link after aborting edit with display_with :link_to" do
      @user.save!
      visit users_path
      within("tr#user_#{@user.id} > .name > span") do
        page.should have_content("Lucia")
        page.should have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
      id = BestInPlace::Utils.build_best_in_place_id @user, :name
      page.execute_script <<-JS
        jQuery("#edit_#{@user.id}").click();
        jQuery("##{id} input[name='name']").blur();
        jQuery("##{id} input[name='name']").blur();
      JS
      within("tr#user_#{@user.id} > .name > span") do
        page.should have_content("Lucia")
        page.should have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
    end

    describe "display_with using a lambda" do
      it "should render the money" do
        @user.save!
        visit user_path(@user)

        within("#money_proc") do
          page.should have_content("$100.00")
        end
      end

      it "should show the new value using the helper after a successful update" do
        @user.save!
        visit user_path(@user)

        bip_text @user, :money_proc, "240"

        within("#money_proc") do
          page.should have_content("$240.00")
        end
      end

      it "should display the original content when editing the form" do
        @user.save!
        retry_on_timeout do
          visit user_path(@user)

          id = BestInPlace::Utils.build_best_in_place_id @user, :money_proc
          page.execute_script <<-JS
            $("##{id}").click();
          JS

          text = page.find("##{id} input").value
          text.should == "100.0"
        end
      end

      it "should display the updated content after editing the field two consecutive times" do
        @user.save!

        retry_on_timeout do
          visit user_path(@user)

          bip_text @user, :money_proc, "40"

          sleep 1

          id = BestInPlace::Utils.build_best_in_place_id @user, :money_proc
          page.execute_script <<-JS
            $("##{id}").click();
          JS

          sleep 1

          text = page.find("##{id} input").value
          text.should == "40"
        end
      end

    end

  end

  it "should display strings with quotes correctly in fields" do
    @user.last_name = "A last name \"with double quotes\""
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} input").value
      text.should == "A last name \"with double quotes\""
    end
  end

  it "should allow me to set texts with quotes with sanitize => false" do
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      bip_area @user, :description, "A <a href=\"http://google.es\">link in this text</a> not sanitized."
      visit double_init_user_path(@user)

      page.should have_link("link in this text", :href => "http://google.es")
    end
  end

  it "should show the input with not-scaped ampersands with sanitize => false" do
    @user.description = "A text with an & and a <b>Raw html</b>"
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :description
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      text = page.find("##{id} textarea").value
      text.should == "A text with an & and a <b>Raw html</b>"
    end
  end

  it "should keep the same value after multipe edits" do
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      bip_area @user, :description, "A <a href=\"http://google.es\">link in this text</a> not sanitized."
      visit double_init_user_path(@user)

      page.should have_link("link in this text", :href => "http://google.es")

      id = BestInPlace::Utils.build_best_in_place_id @user, :description
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      page.find("##{id} textarea").value.should eq("A <a href=\"http://google.es\">link in this text</a> not sanitized.")
    end
  end

  it "should display single- and double-quotes in values appropriately" do
    @user.height = %{5' 6"}
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :height
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      page.find("##{id} select").value.should eq(%{5' 6"})
    end
  end

  it "should save single- and double-quotes in values appropriately" do
    @user.height = %{5' 10"}
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :height
      page.execute_script <<-JS
        $("##{id}").click();
        $("##{id} select").val("5' 7\\\"");
        $("##{id} select").blur();
        $("##{id} select").blur();
      JS

      sleep 1

      @user.reload
      @user.height.should eq(%{5' 7"})
    end
  end

  it "should escape javascript in test helpers" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "Other '); alert('hi');"
      sleep 1

      @user.reload
      @user.last_name.should eq("Other '); alert('hi');")
    end
  end

  it "should save text in database without encoding" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "Other \"thing\""
      sleep 1

      @user.reload
      @user.last_name.should eq("Other \"thing\"")
    end
  end

  it "should not strip html tags" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "<script>alert('hi');</script>"
      within("#last_name") { page.should have_content("<script>alert('hi');</script>") }

      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
      page.execute_script <<-JS
        $("##{id}").click();
      JS

      page.find("##{id} input").value.should eq("<script>alert('hi');</script>")
    end
  end

  it "should generate the select html with the proper current option selected" do
    @user.save!
    visit user_path(@user)
    within("#country") do
      page.should have_content("Italy")
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :country
    page.execute_script <<-JS
      $("##{id}").click();
    JS

    page.should have_css("##{id} select option[value='2'][selected='selected']")
  end

  it "should generate the select with the proper current option without reloading the page" do
    @user.save!
    visit user_path(@user)
    within("#country") do
      page.should have_content("Italy")
    end

    bip_select @user, :country, "France"

    sleep 1 # Increase if browser is slow
    id = BestInPlace::Utils.build_best_in_place_id @user, :country
    page.execute_script <<-JS
      $("##{id}").click();
    JS

    page.should have_css("##{id} select option[value='4'][selected='selected']")
  end
end

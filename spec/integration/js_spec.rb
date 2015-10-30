# encoding: utf-8

describe "JS behaviour", :js => true do
  before do
    @user = User.new :name => "Lucia",
      :last_name => "Napoli",
      :email => "lucianapoli@gmail.com",
      :height => "h51",
      :address => "Via Roma 99",
      :zip => "25123",
      :country => "2",
      :receive_email => false,
      :birth_date => Time.now.utc,
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

      expect(find('#last_name')).to have_content('Napoli')
      bip_text @user, :last_name, "Other thing"

      expect(find('#last_name')).to have_content('Other thing')
    end

    it 'should be able to use another url' do
      @user.save!
      visit admin_user_path(@user)

      expect(find('#name')).to have_content('Lucia')
      bip_text @user, :name, 'Other thing'

      expect(find('#name')).to have_content('Other thing')
    end
  end

  describe "nil option" do
    it "should render an em-dash when the field is empty" do
      @user.name = ""
      @user.save :validate => false
      visit user_path(@user)

      expect(find('#name')).to have_content('-')
    end

    it "should render the default em-dash string when there is an error and if the intial string is em-dash" do
      @user.money = nil
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "abcd"

      expect(find('#money')).to have_content('-')
    end

    it "should render the passed nil value if the field is empty" do
      @user.last_name = ""
      @user.save :validate => false
      visit user_path(@user)

      expect(find('#last_name')).to have_content('Nothing to show')
    end

    it 'should render html content for placeholder option' do
      @user.favorite_color = ""
      @user.save!
      visit user_path(@user)

      expect(find('#favorite_color')).to have_xpath("//span[@class='placeholder']")
      expect(find('#favorite_color')).to have_css('.placeholdered')
    end

    it 'should render html content for placeholder option after edit' do
      @user.favorite_color = "Blue"
      @user.save!
      visit user_path(@user)

      bip_text @user, :favorite_color, ""

      expect(find('#favorite_color')).to have_css('span.placeholder')
      expect(find('#favorite_color')).to have_css('.placeholdered')
    end

    it 'should remove the placeholdered class after adding a value' do
      @user.favorite_color = ""
      @user.save!
      visit user_path(@user)
      expect(find('#favorite_color')).to have_css('.placeholdered')

      bip_text @user, :favorite_color, "blue"
      expect(find('#favorite_color')).to_not have_css('.placeholdered')
    end

    it "should display an empty input field the second time I open it" do
      @user.favorite_locale = nil
      @user.save!
      visit user_path(@user)

      expect(find('#favorite_locale')).to have_content('N/A')

      id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_locale
      find("##{id}").click

      text = find("##{id} input").value
      expect(text).to eq("")

      execute_script <<-JS
        $("##{id} input[name='favorite_locale']").blur()
      JS
      wait_for_ajax

      find("##{id}").click

      text = find("##{id} input").value
      expect(text).to eq("")
    end
  end

  it 'should update the DOM when a field value changes' do
    @user.save!
    visit user_path(@user)

    expect(find('#receive_email')).to have_content('No thanks')

    bip_bool @user, :receive_email

    expect(page).to have_selector('#receive_email span[data-bip-value=true]')
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
      :money => 100,
      :money_proc => 100,
      :favorite_color => 'Red',
      :favorite_books => "The City of Gold and Lead",
      :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem."

    visit users_path
    within("tr#user_#{@user.id} > .name > span") do
      expect(page).to have_content("Lucia")
      expect(page).to have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
    end

    id = BestInPlace::Utils.build_best_in_place_id @user, :name
    find("#edit_#{@user.id}").click
    find("##{id} input[name='name']").set('Lisa')
    execute_script("$('##{id} form').submit();")

    expect(find("tr#user_#{@user.id} > .name > span")).to have_content('Lisa')
  end

  it "should be able to use bip_text to update a text field" do
    @user.save!
    visit user_path(@user)
    expect(find('#email')).to have_content('lucianapoli@gmail.com')

    bip_text @user, :email, "new@email.com"

    expect(find('#email')).to have_content('new@email.com')

    visit user_path(@user)
    expect(find('#email')).to have_content('new@email.com')
  end

  it "should be able to update a field two consecutive times" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :email, "new@email.com"

    expect(find('#email')).to have_content('new@email.com')

    bip_text @user, :email, "new_two@email.com"

    expect(find('#email')).to have_content('new_two@email.com')

    visit user_path(@user)
    expect(find('#email')).to have_content('new_two@email.com')
  end

  it "should be able to update a field after an error" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :email, "wrong format"
    expect(page).to have_content("Email has wrong email format")

    bip_text @user, :email, "another@email.com"

    expect(find('#email')).to have_content('another@email.com')

    visit user_path(@user)

    expect(find('#email')).to have_content('another@email.com')
  end

  it "should be able to use bip_select to change a select field" do
    @user.save!
    visit user_path(@user)

    expect(find('#country')).to have_content('Italy')

    bip_select @user, :country, 'France'

    expect(find('#country')).to have_content('France')

    visit user_path(@user)

    expect(find('#country')).to have_content('France')
  end

  it "should apply the inner_class option to a select field" do
    @user.save!
    visit user_path(@user)

    find('#country span').click
    expect(find('#country')).to have_css('select.some_class')
  end

  it "should be able to use bip_text to change a date field" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)

    expect(find('#birth_date')).to have_content(today)

    bip_text @user, :birth_date, (today - 1.days)

    expect(find('#birth_date')).to have_content(today - 1.days)

    visit user_path(@user)

    expect(find('#birth_date')).to have_content(today - 1.days)
  end

  it "should be able to use datepicker to change a date field" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)

    expect(find('#birth_date')).to have_content(today)

    id = BestInPlace::Utils.build_best_in_place_id @user, :birth_date
    find("##{id}").click
    execute_script <<-JS
      $(".ui-datepicker-calendar tbody td").not(".ui-datepicker-other-month").first().click()
    JS
    wait_for_ajax

    expect(find('#birth_date')).to have_content(today.beginning_of_month.strftime('%d-%m-%Y'))

    visit user_path(@user)

    expect(find('#birth_date')).to have_content(today.beginning_of_month)
  end

  it "should be able to modify the datepicker options, displaying the date with another format" do
    @user.save!
    today = Time.now.utc.to_date
    visit user_path(@user)

    expect(find('#birth_date')).to have_content(today)

    id = BestInPlace::Utils.build_best_in_place_id @user, :birth_date
    find("##{id}").click
    execute_script <<-JS
      $(".ui-datepicker-calendar tbody td").not(".ui-datepicker-other-month").first().click()
    JS


    expect(find('#birth_date')).to have_content(today.beginning_of_month.strftime('%d-%m-%Y'))
  end

  it "should be able to use bip_bool to change the default boolean values" do
    @user.save!
    visit user_path(@user)


    expect(find('#receive_email_default')).to have_content('No')

    bip_bool @user, :receive_email_default

    expect(find('#receive_email_default')).to have_content('Yes')

    visit user_path(@user)

    expect(find('#receive_email_default')).to have_content('Yes')
  end

  it "should be able to use bip_bool to change a boolean value" do
    @user.save!
    visit user_path(@user)


    expect(find('#receive_email')).to have_content('No thanks')

    bip_bool @user, :receive_email

    expect(find('#receive_email')).to have_content('Yes of course')

    visit user_path(@user)

    expect(find('#receive_email')).to have_content('Yes of course')
  end

  it "should be able to use bip_bool to change a boolean value using an image" do
    @user.save!
    visit user_path(@user)


    expect(find('#receive_email_image')).to have_xpath("//img[contains(@src,'no.png')]")

    bip_bool @user, :receive_email_image

    expect(find('#receive_email_image')).to have_xpath("//img[contains(@src,'yes.png')]")

    visit user_path(@user)

    expect(find('#receive_email_image')).to have_xpath("//img[contains(@src,'yes.png')]")
  end

  it "should correctly use an OK submit button when so configured for an input" do
    @user.save!
    visit user_path(@user)


    expect(find('#favorite_color')).to have_content('Red')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    find("##{id}").click
    find("##{id} input[name='favorite_color']").set('Blue')

    expect(find("##{id} input[type='submit']").value).to eq('Do it!')
    expect(page).to have_css("##{id} input[type='submit'].custom-submit.other-custom-submit")
    find("##{id} input[type='submit']").click
    wait_for_ajax

    expect(find('#favorite_color')).to have_content('Blue')

    visit user_path(@user)

    expect(find('#favorite_color')).to have_content('Blue')
  end

  it "should correctly use a Cancel button when so configured for an input" do
    @user.save!
    visit user_path(@user)


    expect(find('#favorite_color')).to have_content('Red')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    find("##{id}").click
    find("##{id} input[name='favorite_color']").set('Blue')

    expect(find("##{id} input[type='button']").value).to eq('Nope')
    expect(page).to have_css("##{id} input[type='button'].custom-cancel.other-custom-cancel")

    find("##{id} input[type='button']").click

    visit user_path(@user)

    expect(find('#favorite_color')).to have_content('Red')
  end

  it "should not ask for confirmation on cancel if it is switched off" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_movie
    find("##{id}").click
    find("##{id} input[name='favorite_movie']").set('No good movie')
    find("##{id} input[type='button']").click

    expect(find('#favorite_movie')).to have_content("The Hitchhiker's Guide to the Galaxy")
  end

  it "should not submit input on blur if there's an OK button present" do
    @user.save!
    visit user_path(@user)

    expect(find('#favorite_color')).to have_content('Red')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    find("##{id}").click
    find("##{id} input[name='favorite_color']").set('Blue')
    execute_script <<-JS
      $("##{id} input[name='favorite_color']").blur();
    JS
    sleep 0.5
    expect(page).to have_css("##{id} input[type='submit']")

    visit user_path(@user)

    expect(find('#favorite_color')).to have_content('Red')
  end

  it "should still submit input on blur if there's only a Cancel button present" do
    @user.save!
    visit user_path(@user, suppress_ok_button: 1)

    expect(find('#favorite_color')).to have_content('Red')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_color
    find(("##{id}")).trigger('click')
    expect(page).to have_no_css("##{id} input[type='submit']")
    find("##{id} input[name='favorite_color']").set 'Blue'
    sleep 1
    execute_script("$('##{id} input[name=\"favorite_color\"]').blur()")
    wait_for_ajax

    expect(find('#favorite_color')).to have_content('Blue')

    visit user_path(@user)

    expect(find('#favorite_color')).to have_content('Blue')
  end

  it "should correctly use an OK submit button when so configured for a text area" do
    @user.save!
    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    find("##{id}").trigger('click')
    find("##{id} textarea").set('1Q84')
    find("##{id} input[type='submit']").click
    wait_for_ajax

    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('1Q84')
  end

  it "should correctly use a Cancel button when so configured for a text area" do
    @user.save!
    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    find("##{id}").click
    find("##{id} textarea").set('1Q84')
    find("##{id} input[type='button']").click

    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')
  end

  it "should not submit text area on blur if there's an OK button present" do
    @user.save!
    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    find("##{id}").click
    find("##{id} textarea").set('1Q84')
    execute_script("$('##{id} textarea').blur()")
    wait_for_ajax

    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')
  end

  it "should still submit text area on blur if there's only a Cancel button present" do
    @user.save!
    visit user_path(@user, suppress_ok_button: 1)

    expect(find('#favorite_books')).to have_content('The City of Gold and Lead')

    id = BestInPlace::Utils.build_best_in_place_id @user, :favorite_books
    find("##{id}").trigger 'click'
    expect(page).to have_no_css("##{id} input[type='submit']")
    find("##{id} textarea").set '1Q84'
    sleep 1
    execute_script("$('##{id} textarea').blur()")
    wait_for_ajax

    visit user_path(@user)

    expect(find('#favorite_books')).to have_content('1Q84')
  end

  it "should show validation errors" do
    @user.save!
    visit user_path(@user)

    bip_text @user, :address, ""
    expect(page).to have_content("Address can't be blank")
    expect(find('#address')).to have_content('Via Roma 99')
  end

  it "should fire off a callback when updating a field" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
    execute_script <<-JS
      $("##{id}").bind('best_in_place:update', function() { $('body').append('Last name was updated!') });
    JS

    expect(page).to have_no_content('Last name was updated!')
    bip_text @user, :last_name, 'Another'
    expect(page).to have_content('Last name was updated!')
  end

  it "should fire off a callback when retrieve success with empty data" do
    @user.save!
    visit user_path(@user)

    id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
    execute_script <<-JS
      $("##{id}").bind('best_in_place:success', function() { $('body').append('Updated successfully!') });
    JS

    expect(page).to have_no_content('Updated successfully!')
    bip_text @user, :last_name, 'Empty'
    expect(page).to have_content('Updated successfully!')
  end

  describe "display_as" do
    it "should render the address with a custom format" do
      @user.save!
      visit user_path(@user)

      expect(find('#address')).to have_content('addr => [Via Roma 99]')
    end

    it "should still show the custom format after an error" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :address, "inva"

      expect(find('#address')).to have_content('addr => [Via Roma 99]')
    end

    it "should show the new result with the custom format after an update" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :address, "New address"

      expect(find('#address')).to have_content('addr => [New address]')
    end

    it "should show default em-dash when the new result with the custom format is nil after an update" do
      @user.save
      visit user_path(@user)

      bip_text @user, :zip, ""

      expect(find('#zip')).to have_content('-')
    end

    it "should be editable after the new result with the custom format is nil because of an update" do
      @user.save
      visit user_path(@user)

      bip_text @user, :zip, ""

      id = BestInPlace::Utils.build_best_in_place_id @user, :zip
      find("##{id}").click

      text = find("##{id} input").value
      expect(text).to eq("")
    end

    it 'should display the original content when editing the form' do
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        id = BestInPlace::Utils.build_best_in_place_id @user, :address
        find("##{id}").click

        text = find("##{id} input").value
        expect(text).to eq('Via Roma 99')
      end
    end

    it "should display the updated content after editing the field two consecutive times" do
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        bip_text @user, :address, "New address"

        id = BestInPlace::Utils.build_best_in_place_id @user, :address
        find("##{id}").click
        wait_for_ajax

        expect(find("##{id} input").value).to eq('New address')
      end
    end

    it "should quote properly the data-original-content attribute" do
      @user.address = "A's & B's"
      @user.save!

      retry_on_timeout do
        visit user_path(@user)
        id = BestInPlace::Utils.build_best_in_place_id @user, :address

        text = find("##{id}")['data-bip-original-content']
        expect(text).to eq("A's & B's")
      end
    end
  end

  describe "display_with" do
    it "should show nil text when original value is nil" do
      @user.description = ""
      @user.save!

      visit user_path(@user)

      expect(find('#dw_description')).to have_content('-')
    end

    it "should render the money using number_to_currency" do
      @user.save!
      visit user_path(@user)

      expect(find('#money')).to have_content('$100.00')
    end

    it "should let me use custom helpers with a lambda" do
      @user.save!
      visit user_path(@user)

      expect(page).to have_content("100.0 €")
      bip_text @user, :money_custom, "250"

      expect(find('#money_custom')).to have_content('250.0 €')
    end

    it "should still show the custom format after an error" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "string"

      expect(page).to have_content("Money is not a number")

      expect(find('#money')).to have_content('$100.00')
    end

    it "should show the new value using the helper after a successful update" do
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "240"

      expect(find('#money')).to have_content('$240.00')
    end

    it "should show the new value using the helper after a successful update if original value is nil" do
      @user.money = nil
      @user.save!
      visit user_path(@user)

      bip_text @user, :money, "240"

      expect(find('#money')).to have_content('$240.00')
    end

    it "should display the original content when editing the form" do
      @user.save!
      retry_on_timeout do
        visit user_path(@user)

        id = BestInPlace::Utils.build_best_in_place_id @user, :money
        find("##{id}").click

        text = find("##{id} input").value
        expect(text).to eq("100.0")
      end
    end

    it "should display the updated content after editing the field two consecutive times" do
      @user.save!

      retry_on_timeout do
        visit user_path(@user)

        bip_text @user, :money, "40"

        id = BestInPlace::Utils.build_best_in_place_id @user, :money
        find("##{id}").click
        wait_for_ajax

        text = find("##{id} input").value
        expect(text).to eq("40")
      end
    end

    it "should show the money in euros" do
      @user.save!
      visit double_init_user_path(@user)

      expect(find('#alt_money')).to have_content('€100.00')

      bip_text @user, :money, 58

      expect(find('#alt_money')).to have_content('€58.00')
    end

    it "should keep link after edit with display_with :link_to" do
      @user.save!
      visit users_path
      within("tr#user_#{@user.id} > .name > span") do
        expect(page).to have_content("Lucia")
        expect(page).to have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
      id = BestInPlace::Utils.build_best_in_place_id @user, :name
      find("#edit_#{@user.id}").click
      find("##{id} input[name='name']").set('Maria Lucia')
      within("tr#user_#{@user.id} > .name > span") do
        expect(page).to have_content('Maria Lucia')
        expect(page).to have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
    end

    it "should keep link after aborting edit with display_with :link_to" do
      @user.save!
      visit users_path
      within("tr#user_#{@user.id} > .name > span") do
        expect(page).to have_content("Lucia")
        expect(page).to have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
      id = BestInPlace::Utils.build_best_in_place_id @user, :name
      find("#edit_#{@user.id}").click
      execute_script("$('##{id} input[name=\"name\"]').blur();")
      within("tr#user_#{@user.id} > .name > span") do
        expect(page).to have_content("Lucia")
        expect(page).to have_xpath("//a[contains(@href,'#{user_path(@user)}')]")
      end
    end

    describe "display_with using a lambda" do
      it "should render the money" do
        @user.save!
        visit user_path(@user)

        expect(find('#money_proc')).to have_content('$100.00')
      end

      it "should show the new value using the helper after a successful update" do
        @user.save!
        visit user_path(@user)

        bip_text @user, :money_proc, "240"

        expect(find('#money_proc')).to have_content('$240.00')
      end

      it "should display the original content when editing the form" do
        @user.save!
        retry_on_timeout do
          visit user_path(@user)

          id = BestInPlace::Utils.build_best_in_place_id @user, :money_proc
          find("##{id}").click

          text = find("##{id} input").value
          expect(text).to eq("100.0")
        end
      end

      it "should display the updated content after editing the field two consecutive times" do
        @user.save!

        retry_on_timeout do
          visit user_path(@user)
          bip_text @user, :money_proc, "40"

          id = BestInPlace::Utils.build_best_in_place_id @user, :money_proc
          find("##{id}").click
          wait_for_ajax

          expect(find("##{id} input").value).to eq('40')
        end
      end

    end

  end

  describe 'value' do
    it 'should use custom value in input' do
      @user.save!
      visit user_path(@user)

      find('#money_value .best_in_place').click
      expect(page).to have_field('money_value', with: 'Custom Value')
    end
    it 'should not use default value in input with value set' do
      @user.save!
      visit user_path(@user)

      find('#money_value .best_in_place').click
      expect(page).not_to have_field('money', with: @user.money)
    end
  end

  it "should display strings with quotes correctly in fields" do
    @user.last_name = "A last name \"with double quotes\""
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
      find("##{id}").click

      expect(find("##{id} input").value).to eq("A last name \"with double quotes\"")
    end
  end

  it 'should texts with quotes with raw => true' do
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      bip_area @user, :description, "A <a href=\"http://google.es\">link in this text</a> not sanitized."

      expect(page).to have_link("link in this text", :href => "http://google.es")

      visit double_init_user_path(@user)

      expect(page).to have_link("link in this text", :href => "http://google.es")
    end
  end

  it "should show the input with not-scaped ampersands with raw => true" do
    @user.description = "A text with an & and a <b>Raw html</b>"
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :description
      find("##{id}").click

      text = find("##{id} textarea").value
      expect(text).to eq("A text with an & and a <b>Raw html</b>")
    end
  end

  it "should keep the same value after multipe edits" do
    @user.save!

    retry_on_timeout do
      visit double_init_user_path(@user)

      bip_area @user, :description, "A <a href=\"http://google.es\">link in this text</a> not sanitized."
      visit double_init_user_path(@user)

      expect(page).to have_link("link in this text", :href => "http://google.es")

      id = BestInPlace::Utils.build_best_in_place_id @user, :description
      find("##{id}").click

      expect(find("##{id} textarea").value).to eq("A <a href=\"http://google.es\">link in this text</a> not sanitized.")
    end
  end

  it "should display single- and double-quotes in values appropriately" do
    @user.height = %{5' 6"}
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :height
      find("##{id}").click

      expect(find("##{id} select").value).to eq(%{5' 6"})
    end
  end

  it "should save single- and double-quotes in values appropriately" do
    @user.height = %{5' 10"}
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :height
      find("##{id}").click
      execute_script <<-JS
        $("##{id} select").val("5' 7\\\"");
        $("##{id} select").blur();
      JS
      wait_for_ajax

      @user.reload
      expect(@user.height).to eq(%{5' 7"})
    end
  end

  it "should escape javascript in test helpers" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "Other '); alert('hi');"

      @user.reload
      expect(@user.last_name).to eq("Other '); alert('hi');")
    end
  end

  it "should save text in database without encoding" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "Other \"thing\""

      @user.reload
      expect(@user.last_name).to eq("Other \"thing\"")
    end
  end

  it "should not strip html tags" do
    @user.save!

    retry_on_timeout do
      visit user_path(@user)

      bip_text @user, :last_name, "<script>alert('hi');</script>"
      expect(find('#last_name')).to have_content("<script>alert('hi');</script>")

      visit user_path(@user)

      id = BestInPlace::Utils.build_best_in_place_id @user, :last_name
      find("##{id}").click

      expect(find("##{id} input").value).to eq("<script>alert('hi');</script>")
    end
  end

  it "should generate the select html with the proper current option selected" do
    @user.save!
    visit user_path(@user)
    expect(find('#country')).to have_content('Italy')

    id = BestInPlace::Utils.build_best_in_place_id @user, :country
    find("##{id}").click
    wait_for_ajax

    expect(page).to have_css("##{id} select option[value='2'][selected='selected']")
  end

  it "should generate the select with the proper current option without reloading the page" do
    @user.save!
    visit user_path(@user)
    expect(find('#country')).to have_content('Italy')

    bip_select @user, :country, "France"

    id = BestInPlace::Utils.build_best_in_place_id @user, :country
    find("##{id}").click

    expect(page).to have_css("##{id} select option[value='4'][selected='selected']")
  end
end

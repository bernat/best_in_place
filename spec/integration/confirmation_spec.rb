# encoding: utf-8
require "spec_helper"

feature "Confirmation", :js => true do
  background do
    @user = User.create :name => "Lucia",
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

  context 'if accepted' do
    background do
      visit user_path(@user, confirmation: 'Are you sure?')
    end

    scenario 'should update object for text field' do
      bip_text(@user, :last_name, 'jopa')
      page.driver.browser.switch_to.alert.accept

      page.should have_content('jopa')
      @user.reload.last_name.should == 'jopa'
    end

    scenario 'should update object for select' do
      bip_select(@user, :country, 'Russia')
      page.driver.browser.switch_to.alert.accept

      page.should have_content('Russia')
      @user.reload.country.should == '5'
    end

    scenario 'should update object for textarea' do
      bip_area(@user, :description, 'Big')
      page.driver.browser.switch_to.alert.accept

      page.should have_content('Big')
      @user.reload.description.should == 'Big'
    end

    scenario 'should update object for checkbox' do
      bip_bool(@user, :receive_email)
      page.driver.browser.switch_to.alert.accept

      page.should have_content('Yes of course')
      @user.reload.receive_email.should == true
    end

    scenario 'should update object for date' do
      today = Time.now.utc.to_date
      bip_text(@user, :birth_date, today - 1.days)
      page.driver.browser.switch_to.alert.accept

      page.should have_content(today - 1.days)
      @user.reload.birth_date.should == today - 1.days
    end
  end

  context 'if rejected' do
    background do
      visit user_path(@user, confirmation: 'Are you sure?')
      @old_user = @user
    end

    scenario 'should not update object for text field' do
      bip_text(@user, :last_name, 'jopa')
      page.driver.browser.switch_to.alert.dismiss

      page.should have_content(@old_user.last_name)
      @user.reload.last_name.should == @old_user.last_name
    end

    scenario 'should not update object for select' do
      bip_select(@user, :country, 'Russia')
      page.driver.browser.switch_to.alert.dismiss

      page.should have_content(@old_user.country)
      @user.reload.country.should == @old_user.country
    end

    scenario 'should not update object for textarea' do
      bip_area(@user, :description, 'Big')
      page.driver.browser.switch_to.alert.dismiss

      page.should have_content(@old_user.description)
      @user.reload.description.should == @old_user.description
    end

    scenario 'should not update object for checkbox' do
      bip_bool(@user, :receive_email)
      page.driver.browser.switch_to.alert.dismiss

      page.should have_content('No thanks')
      @user.reload.receive_email.should == false
    end

    scenario 'should update object for date' do
      today = Time.now.utc.to_date
      bip_text(@user, :birth_date, today - 1.days)
      page.driver.browser.switch_to.alert.dismiss

      page.should have_content(@old_user.birth_date)
      @user.reload.birth_date.should == @old_user.birth_date
    end
  end

  scenario 'should not raise alert window if confirmation message blank' do
    visit user_path(@user, confirmation: '')

    bip_bool(@user, :receive_email)
    expect{ page.driver.browser.switch_to.alert }.to raise_exception(Selenium::WebDriver::Error::NoAlertPresentError)
  end

  context 'accept after after confirmation rejected' do
    it 'should update object for checkbox' do
      visit user_path(@user, confirmation: 'Are you sure?')

      bip_bool(@user, :receive_email)
      page.driver.browser.switch_to.alert.dismiss

      bip_bool(@user, :receive_email)
      page.driver.browser.switch_to.alert.accept

      page.should have_content('Yes of course')
      @user.reload.receive_email.should == true
    end
  end
end

# encoding: utf-8
require "spec_helper"

describe BestInPlace::BestInPlaceHelpers do
  describe "#best_in_place" do
    before do
      @user = User.new :name => "Lucia",
        :last_name => "Napoli",
        :email => "lucianapoli@gmail.com",
        :height => "5' 5\"",
        :address => "Via Roma 99",
        :zip => "25123",
        :country => "2",
        :receive_email => false,
        :birth_date => Time.now.utc.to_date,
        :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
        :money => 150
    end

    it "should generate a proper id for namespaced models" do
      @car = Cuca::Car.create :model => "Ford"

      nk = Nokogiri::HTML.parse(helper.best_in_place @car, :model, :path => helper.cuca_cars_path)
      span = nk.css("span")
      span.attribute("id").value.should == "best_in_place_cuca_car_#{@car.id}_model"
    end

    it "should generate a proper span" do
      nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
      span = nk.css("span")
      span.should_not be_empty
    end

    it "should not allow both display_as and display_with option" do
      lambda { helper.best_in_place(@user, :money, :display_with => :number_to_currency, :display_as => :custom) }.should raise_error(ArgumentError)
    end

    describe "general properties" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      context "when it's an ActiveRecord model" do
        it "should have a proper id" do
          @span.attribute("id").value.should == "best_in_place_user_#{@user.id}_name"
        end
      end

      context "when it's not an AR model" do
        it "shold generate an html id without any id" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [1,2,3], :first, :path => @user)
          span = nk.css("span")
          span.attribute("id").value.should == "best_in_place_array_first"
        end
      end

      it "should have the best_in_place class" do
        @span.attribute("class").value.should == "best_in_place"
      end

      it "should have the correct data-attribute" do
        @span.attribute("data-attribute").value.should == "name"
      end

      it "should have the correct data-object" do
        @span.attribute("data-object").value.should == "user"
      end

      it "should have no activator by default" do
        @span.attribute("data-activator").should be_nil
      end

      it "should have no OK button text by default" do
        @span.attribute("data-ok-button").should be_nil
      end

      it "should have no OK button class by default" do
        @span.attribute("data-ok-button-class").should be_nil
      end

      it "should have no Cancel button text by default" do
        @span.attribute("data-cancel-button").should be_nil
      end

      it "should have no Cancel button class by default" do
        @span.attribute("data-cancel-button-class").should be_nil
      end

      it "should have no Use-Confirmation dialog option by default" do
        @span.attribute("data-use-confirm").should be_nil
      end

      it "should have no inner_class by default" do
        @span.attribute("data-inner-class").should be_nil
      end

      describe "url generation" do
        it "should have the correct default url" do
          @user.save!
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users/#{@user.id}"
        end

        it "should use the custom url specified in string format" do
          out = helper.best_in_place @user, :name, :path => "/custom/path"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/custom/path"
        end

        it "should use the path given in a named_path format" do
          out = helper.best_in_place @user, :name, :path => helper.users_path
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users"
        end

        it "should use the given path in a hash format" do
          out = helper.best_in_place @user, :name, :path => {:controller => :users, :action => :edit, :id => 23}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-url").value.should == "/users/23/edit"
        end
      end

      describe "nil option" do
        it "should have no nil data by default" do
          @span.attribute("data-nil").should be_nil
        end

        it "should show '' if the object responds with nil for the passed attribute" do
          @user.stub!(:name).and_return(nil)
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.text.should == ""
        end

        it "should show '' if the object responds with an empty string for the passed attribute" do
          @user.stub!(:name).and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          span.text.should == ""
        end
      end

      it "should have the given inner_class" do
        out = helper.best_in_place @user, :name, :inner_class => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-inner-class").value.should == "awesome"
      end

      it "should have the given activator" do
        out = helper.best_in_place @user, :name, :activator => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-activator").value.should == "awesome"
      end

      it "should have the given OK button text" do
        out = helper.best_in_place @user, :name, :ok_button => "okay"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-ok-button").value.should == "okay"
      end

      it "should have the given OK button class" do
        out = helper.best_in_place @user, :name, :ok_button => "okay", :ok_button_class => "okay-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-ok-button-class").value.should == "okay-class"
      end

      it "should have the given Cancel button text" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-cancel-button").value.should == "nasty"
      end

      it "should have the given Cancel button class" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty", :cancel_button_class => "nasty-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-cancel-button-class").value.should == "nasty-class"
      end

      it "should have the given Use-Confirmation dialog option" do
        out = helper.best_in_place @user, :name, :use_confirm => "false"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-use-confirm").value.should == "false"
      end

      describe "object_name" do
        it "should change the data-object value" do
          out = helper.best_in_place @user, :name, :object_name => "my_user"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.attribute("data-object").value.should == "my_user"
        end
      end

      it "should have html5 data attributes" do
        out = helper.best_in_place @user, :name, :data => { :foo => "awesome", :bar => "nasty" }
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        span.attribute("data-foo").value.should == "awesome"
        span.attribute("data-bar").value.should == "nasty"
      end

      describe "display_as" do
        it "should render the address with a custom renderer" do
          @user.should_receive(:address_format).and_return("the result")
          out = helper.best_in_place @user, :address, :display_as => :address_format
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.text.should == "the result"
        end
      end

      describe "display_with" do
        it "should render the money with the given view helper" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.text.should == "$150.00"
        end

        it "accepts a proc" do
          out = helper.best_in_place @user, :name, :display_with => Proc.new { |v| v.upcase }
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.text.should == "LUCIA"
        end

        it "should raise an error if the given helper can't be found" do
          lambda { helper.best_in_place @user, :money, :display_with => :fk_number_to_currency }.should raise_error(ArgumentError)
        end

        it "should call the helper method with the given arguments" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency, :helper_options => {:unit => "º"}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          span.text.should == "º150.00"
        end
      end

      describe "array-like objects" do
        it "should work with array-like objects in order to provide support to namespaces" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @user], :name)
          span = nk.css("span")
          span.text.should == "Lucia"
        end
      end
    end

    context "with a text field attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      it "should render the name as text" do
        @span.text.should == "Lucia"
      end

      it "should have an input data-type" do
        @span.attribute("data-type").value.should == "input"
      end

      it "should have no data-collection" do
        @span.attribute("data-collection").should be_nil
      end
    end

    context "with a date attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :birth_date, :type => :date)
        @span = nk.css("span")
      end

      it "should render the date as text" do
        @span.text.should == @user.birth_date.to_date.to_s
      end

      it "should have a date data-type" do
        @span.attribute("data-type").value.should == "date"
      end

      it "should have no data-collection" do
        @span.attribute("data-collection").should be_nil
      end
    end

    context "with a boolean attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox)
        @span = nk.css("span")
      end

      it "should have a checkbox data-type" do
        @span.attribute("data-type").value.should == "checkbox"
      end

      it "should have the default data-collection" do
        data = ["No", "Yes"]
        @span.attribute("data-collection").value.should == data.to_json
      end

      it "should render the current option as No" do
        @span.text.should == "No"
      end

      describe "custom collection" do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox, :collection => ["Nain", "Da"])
          @span = nk.css("span")
        end

        it "should show the message with the custom values" do
          @span.text.should == "Nain"
        end

        it "should render the proper data-collection" do
          @span.attribute("data-collection").value.should == ["Nain", "Da"].to_json
        end
      end

      describe "actual checkbox" do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, :type => :checkbox, :collection => [:actual_checkbox])
          @span = nk.css('input')
        end

        it "should be an unchecked checkbox" do
          @span.should have_selector('input', :type => 'checkbox')
        end
      end

    end

    context "with a select attribute" do
      before do
        @countries = COUNTRIES.to_a
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, :type => :select, :collection => @countries)
        @span = nk.css("span")
      end

      it "should have a select data-type" do
        @span.attribute("data-type").value.should == "select"
      end

      it "should have a proper data collection" do
        @span.attribute("data-collection").value.should == @countries.to_json
      end

      it "should show the current country" do
        @span.text.should == "Italy"
      end

      it "should include the proper data-value" do
        @span.attribute("data-value").value.should == "2"
      end

      context "with an apostrophe in it" do
        before do
          @apostrophe_countries = [[1, "Joe's Country"], [2, "Bob's Country"]]
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, :type => :select, :collection => @apostrophe_countries)
          @span = nk.css("span")
        end

        it "should have a proper data collection" do
          @span.attribute("data-collection").value.should == @apostrophe_countries.to_json
        end
      end
    end
  end

  describe "#best_in_place_if" do
    context "when the parameters are valid" do
      before do
        @user = User.new :name => "Lucia",
          :last_name => "Napoli",
          :email => "lucianapoli@gmail.com",
          :height => "5' 5\"",
          :address => "Via Roma 99",
          :zip => "25123",
          :country => "2",
          :receive_email => false,
          :birth_date => Time.now.utc.to_date,
          :description => "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a lectus et lacus ultrices auctor. Morbi aliquet convallis tincidunt. Praesent enim libero, iaculis at commodo nec, fermentum a dolor. Quisque eget eros id felis lacinia faucibus feugiat et ante. Aenean justo nisi, aliquam vel egestas vel, porta in ligula. Etiam molestie, lacus eget tincidunt accumsan, elit justo rhoncus urna, nec pretium neque mi et lorem. Aliquam posuere, dolor quis pulvinar luctus, felis dolor tincidunt leo, eget pretium orci purus ac nibh. Ut enim sem, suscipit ac elementum vitae, sodales vel sem.",
          :money => 150
        @options = {}
      end

      context "when the condition is true" do
        before {@condition = true}

        it "should work with array-like objects in order to provide support to namespaces" do
          nk = Nokogiri::HTML.parse(helper.best_in_place_if @condition, [:admin, @user], :name)
          span = nk.css("span")
          span.text.should == "Lucia"
        end

        context "when the options parameter is left off" do
          it "should call best_in_place with the rest of the parameters and empty options" do
            helper.should_receive(:best_in_place).with(@user, :name, {})
            helper.best_in_place_if @condition, @user, :name
          end
        end

        context "when the options parameter is included" do
          it "should call best_in_place with the rest of the parameters" do
            helper.should_receive(:best_in_place).with(@user, :name, @options)
            helper.best_in_place_if @condition, @user, :name, @options
          end
        end
      end

      context "when the condition is false" do
        before {@condition = false}

        it "should work with array-like objects in order to provide support to namespaces" do
          helper.best_in_place_if(@condition, [:admin, @user], :name).should eq "Lucia"
        end

        it "should return the value of the field when the options value is left off" do
          helper.best_in_place_if(@condition, @user, :name).should eq "Lucia"
        end

        it "should return the value of the field when the options value is included" do
          helper.best_in_place_if(@condition, @user, :name, @options).should eq "Lucia"
        end
      end
    end
  end
end

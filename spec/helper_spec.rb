# encoding: utf-8

describe BestInPlace::Helper, type: :helper do
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

      nk = Nokogiri::HTML.parse(helper.best_in_place @car, :model, url: helper.cuca_cars_path)
      span = nk.css("span")
      expect(span.attribute("id").value).to eq("best_in_place_cuca_car_#{@car.id}_model")
    end

    it "should generate a proper span" do
      nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
      span = nk.css("span")
      expect(span).not_to be_empty
    end

    it "should show deprecation warning" do
      expect(ActiveSupport::Deprecation).to receive(:warn).with("[Best_in_place] :path is deprecated in favor of :url ")

      helper.best_in_place @user, :name, path: "http://example.com"
    end

    it "should not allow both display_as and display_with option" do
      expect { helper.best_in_place(@user, :money, :display_with => :number_to_currency, :display_as => :custom) }.to raise_error(ArgumentError)
    end

    describe "general properties" do
      before do
        @user.save
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      context "when it's an ActiveRecord model" do
        it "should have a proper id" do
          expect(@span.attribute("id").value).to eq("best_in_place_user_#{@user.id}_name")
        end
      end

      it "should have the best_in_place class" do
        expect(@span.attribute("class").value).to eq("best_in_place")
      end

      it "should have the correct data-bip-attribute" do
        expect(@span.attribute("data-bip-attribute").value).to eq("name")
      end

      it "should have the correct data-bip-object" do
        expect(@span.attribute("data-bip-object").value).to eq("user")
      end

      it "should have no activator by default" do
        expect(@span.attribute("data-bip-activator")).to be_nil
      end

      it "should have no OK button text by default" do
        expect(@span.attribute("data-bip-ok-button")).to be_nil
      end

      it "should have no OK button class by default" do
        expect(@span.attribute("data-bip-ok-button-class")).to be_nil
      end

      it "should have no Cancel button text by default" do
        expect(@span.attribute("data-bip-cancel-button")).to be_nil
      end

      it "should have no Cancel button class by default" do
        expect(@span.attribute("data-bip-cancel-button-class")).to be_nil
      end

      it "should have no Use-Confirmation dialog option by default" do
        expect(@span.attribute("data-bip-confirm")).to be_nil
      end

      it "should have no inner_class by default" do
        expect(@span.attribute("data-bip-inner-class")).to be_nil
      end


      it "should have be sanitized by default" do
        expect(@span.attribute("data-bip-raw")).to be_nil
      end

      describe "url generation" do
        it "should have the correct default url" do
          @user.save!
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.attribute("data-bip-url").value).to eq("/users/#{@user.id}")
        end

        it "should use the custom url specified in string format" do
          out = helper.best_in_place @user, :name, url: "/custom/path"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-bip-url").value).to eq("/custom/path")
        end

        it "should use the path given in a named_path format" do
          out = helper.best_in_place @user, :name, url: helper.users_path
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-bip-url").value).to eq("/users")
        end

        it "should use the given path in a hash format" do
          out = helper.best_in_place @user, :name, url: {:controller => :users, :action => :edit, :id => 23}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-bip-url").value).to eq("/users/23/edit")
        end
      end

      describe "placeholder option" do
        it "should have no placeholder data by default" do
          expect(@span.attribute("data-bip-placeholder")).to be_nil
        end

        it "should show '' if the object responds with placeholder for the passed attribute" do
          expect(@user).to receive(:name).twice.and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.text).to eq("")
        end

        it "should show '' if the object responds with an empty string for the passed attribute" do
          expect(@user).to receive(:name).twice.and_return("")
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
          span = nk.css("span")
          expect(span.text).to eq("")
        end

      end

      it "should have the given inner_class" do
        out = helper.best_in_place @user, :name, :inner_class => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-inner-class").value).to eq("awesome")
      end

      it "should have the given activator" do
        out = helper.best_in_place @user, :name, :activator => "awesome"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-activator").value).to eq("awesome")
      end

      it "should have the given OK button text" do
        out = helper.best_in_place @user, :name, :ok_button => "okay"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-ok-button").value).to eq("okay")
      end

      it "should have the given OK button class" do
        out = helper.best_in_place @user, :name, :ok_button => "okay", :ok_button_class => "okay-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-ok-button-class").value).to eq("okay-class")
      end

      it "should have the given Cancel button text" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-cancel-button").value).to eq("nasty")
      end

      it "should have the given Cancel button class" do
        out = helper.best_in_place @user, :name, :cancel_button => "nasty", :cancel_button_class => "nasty-class"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-bip-cancel-button-class").value).to eq("nasty-class")
      end

      it 'should have the given Confirmation dialog option' do
        out = helper.best_in_place @user, :name, :confirm => "false"
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute('data-bip-confirm').value).to eq('false')
      end

      it "should be raw" do
        out = helper.best_in_place @user, :name, raw: true
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute('data-bip-raw').value).to eq('true')
      end

      it 'should not satinize if raw is true' do
        @user.description = '<h1>Raw text</h1>'
        out = helper.best_in_place @user, :description, raw: true
        nk = Nokogiri::HTML.parse(out)
        span = nk.css('span')
        expect(span.css('h1')).to_not be_empty
      end

      describe "object_name" do
        it "should change the data-bip-object value" do
          out = helper.best_in_place @user, :name, param: "my_user"
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.attribute("data-bip-object").value).to eq("my_user")
        end
      end

      it "should have html5 data attributes" do
        out = helper.best_in_place @user, :name, :data => { :foo => "awesome", :bar => "nasty" }
        nk = Nokogiri::HTML.parse(out)
        span = nk.css("span")
        expect(span.attribute("data-foo").value).to eq("awesome")
        expect(span.attribute("data-bar").value).to eq("nasty")
      end

      describe "display_as" do
        it "should render the address with a custom renderer" do
          expect(@user).to receive(:address_format).and_return("the result")
          out = helper.best_in_place @user, :address, :display_as => :address_format
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("the result")
        end
      end

      describe "display_with" do
        it "should render the money with the given view helper" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("$150.00")
        end

        it "accepts a proc" do
          out = helper.best_in_place @user, :name, :display_with => Proc.new { |v| v.upcase }
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("LUCIA")
        end

        it "should raise an error if the given helper can't be found" do
          expect { helper.best_in_place @user, :money, :display_with => :fk_number_to_currency }.to raise_error(ArgumentError)
        end

        it "should call the helper method with the given arguments" do
          out = helper.best_in_place @user, :money, :display_with => :number_to_currency, :helper_options => {:unit => "º"}
          nk = Nokogiri::HTML.parse(out)
          span = nk.css("span")
          expect(span.text).to eq("º150.00")
        end
      end

      describe "array-like objects" do
        it "should work with array-like objects in order to provide support to namespaces" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @user], :name)
          span = nk.css("span")
          expect(span.text).to eq("Lucia")
        end
      end
    end

    context "with a new record and associations" do
      before do
        @user.save
        @test_result = TestResult.new name: 'Meyers-Briggs', user_id: @user.id
      end

      describe "url generation" do
        it "should have the correct default url" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @test_result], :result)
          span = nk.css("span")
          expect(span.attribute("data-bip-url").value).to eq("/admin/test_results")
        end

        it "should set the new-object data param" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @test_result], :result)
          span = nk.css("span")
          expect(span.attribute("data-bip-new-object").value).to be_truthy
        end

        it "should set the extra-payload data param to a hash of all the unsaved attribs of the model" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @test_result], :result)
          span = nk.css("span")
          expect(span.attribute("data-bip-extra-payload").value).to eq %Q!{"name":"Meyers-Briggs","user_id":#{@user.id}}!
        end

        it "should have a proper DOM id for the container" do
          nk = Nokogiri::HTML.parse(helper.best_in_place [:admin, @test_result], :result)
          span = nk.css("span")
          expect(span.attribute("id").value).to eq("best_in_place_test_result_result")
        end
      end
    end

    context "with a text field attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        @span = nk.css("span")
      end

      it "should render the name as text" do
        expect(@span.text).to eq("Lucia")
      end

      it 'should have an input data-bip-type' do
        expect(@span.attribute('data-bip-type').value).to eq('input')
      end

      it 'should have no data-bip-collection' do
        expect(@span.attribute('data-bip-collection')).to be_nil
      end
    end

    context "with a date attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :birth_date, as: :date)
        @span = nk.css("span")
      end

      it "should render the date as text" do
        expect(@span.text).to eq(@user.birth_date.to_date.to_s)
      end

      it "should have a date data-bip-type" do
        expect(@span.attribute("data-bip-type").value).to eq("date")
      end

      it "should have no data-bip-collection" do
        expect(@span.attribute("data-bip-collection")).to be_nil
      end
    end

    context "with a boolean attribute" do
      before do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, as: :checkbox)
        @span = nk.css("span")
      end

      it "should have a checkbox data-bip-type" do
        expect(@span.attribute("data-bip-type").value).to eq("checkbox")
      end

      it "should have the default data-bip-collection" do
        expect(@span.attribute("data-bip-collection").value).to eq("[[\"true\",\"Yes\"],[\"false\",\"No\"]]")
      end

      it "should render the current option as No" do
        expect(@span.text).to eq("No")
      end

      describe "custom hash collection" do
        before do
          @collection = {false: 'Nain', true: 'Da'}
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, as: :checkbox, collection: @collection)
          @span = nk.css("span")
        end

        it "should show the message with the custom values" do
          expect(@span.text).to eq("Nain")
        end

        it "should render the proper data-bip-collection" do
          expect(@span.attribute("data-bip-collection").value).to eq(@collection.to_a.to_json)
        end
      end

      describe "custom array collection" do
        before do
          @good_collection = ['Net', 'Da']
          @bad_collection = ['Maybe']
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :receive_email, as: :checkbox, collection: @good_collection)
          @span = nk.css("span")
        end

        it "should show the message with the custom values" do
          expect(@span.text).to eq("Net")
        end

        it 'should render the proper data-bip-collection' do
          expect(@span.attribute('data-bip-collection').value).to eq([['false', @good_collection[0]], ['true', @good_collection[1]]].to_json)
        end

        it "should raise an argument error on bad collection" do
          expect { helper.best_in_place @user, :receive_email, as: :checkbox, collection: @bad_collection }.to raise_error(ArgumentError)
        end
      end

    end

    context 'with a select attribute' do
      before do
        @countries_hash = COUNTRIES_HASH
        @countries_hash_string_keys = COUNTRIES_HASH_STRING_KEYS
        @countries_array = COUNTRIES_ARRAY
        @countries_array_of_arrays = COUNTRIES_ARRAY_OF_ARRAYS
        @apostrophe_countries_hash = COUNTRIES_APOSTROPHE_HASH
        @apostrophe_countries_array = COUNTRIES_APOSTROPHE_ARRAY
      end

      describe 'with a hash parameter' do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @countries_hash)
          @span = nk.css('span')
        end

        it 'should have a select data-bip-type' do
          expect(@span.attribute('data-bip-type').value).to eq('select')
        end

        it 'should have a proper data collection' do
          expect(@span.attribute('data-bip-collection').value).to eq(@countries_hash.to_a.to_json)
        end

        it 'should show the current country' do
          expect(@span.text).to eq('Italy')
        end

        it 'should include the proper data-bip-value' do
          expect(@span.attribute('data-bip-value').value).to eq('2')
        end

        context 'with hash string keys' do
          before do
            @user.country = 'it'
            @user.save
            nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @countries_hash_string_keys)
            @span = nk.css('span')
          end

          it 'should have a proper data collection' do
            expect(@span.attribute('data-bip-collection').value).to eq(@countries_hash_string_keys.to_a.to_json)
          end

          it 'should show the current country' do
            expect(@span.text).to eq('Italy')
          end

          it 'should include the proper data-bip-value' do
            expect(@span.attribute('data-bip-value').value).to eq('it')
          end
        end

        context 'with an apostrophe in it' do
          before do
            nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @apostrophe_countries_hash)
            @span = nk.css('span')
          end

          it 'should have a proper data collection' do
            expect(@span.attribute('data-bip-collection').value).to eq(@apostrophe_countries_hash.to_a.to_json)
          end
        end
      end

      describe 'with an array parameter' do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @countries_array)
          @span = nk.css('span')
        end

        it 'should have a proper data collection' do
          expect(@span.attribute('data-bip-collection').value).to eq(@countries_array.each_with_index.map{|a,i| [i+1,a]}.to_json)
        end

        it 'should show the current country' do
          expect(@span.text).to eq('Italy')
        end

        it 'should include the proper data-bip-value' do
          expect(@span.attribute('data-bip-value').value).to eq('2')
        end

        context 'with an apostrophe in it' do
          before do
            nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @apostrophe_countries_array)
            @span = nk.css('span')
          end

          it 'should have a proper data collection' do
            expect(@span.attribute('data-bip-collection').value).to eq(@apostrophe_countries_array.each_with_index.map{|a,i| [i+1,a]}.to_json)
          end
        end
      end

      describe 'with an array parameter' do
        before do
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :country, as: :select, collection: @countries_array_of_arrays)
          @span = nk.css('span')
        end

        it 'should have a proper data collection' do
          expect(@span.attribute('data-bip-collection').value).to eq(@countries_array_of_arrays.to_json)
        end

        it 'should show the current country' do
          expect(@span.text).to eq('Italy')
        end

        it 'should include the proper data-bip-value' do
          expect(@span.attribute('data-bip-value').value).to eq('2')
        end

      end

      describe "with html parameters" do
        before do
          @attrs = {tabindex: 1, width: "300px", height: "24px"}
          nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name, @attrs)
          @span = nk.css("span")
        end

        it 'should pass through html attributes to the best_in_place span' do
          expect(@attrs.select {|key, value| @span.attribute(key.to_s) }).to eq(@attrs)
        end

        it 'should have the proper values set' do
          expect(@attrs.map {|key, value| @span.attribute(key.to_s).value }).to eq(@attrs.map {|key, value| value.to_s })
        end

      end

    end

    context 'custom container' do
      before(:each) do
        @old_container = BestInPlace.container
        @user.save
        BestInPlace.container  = :p
      end

      it 'should override container globally' do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name)
        expect(nk.css('p')).to_not be_empty
      end

      it 'should use the container params' do
        nk = Nokogiri::HTML.parse(helper.best_in_place @user, :name, container: :div)
        expect(nk.css('div')).to_not be_empty
      end

      after(:each) do
        BestInPlace.container = @old_container
      end
    end

    context '.configure' do
      describe 'skip_blur' do
        before(:each) do
          @old_skip_blur = BestInPlace.skip_blur
          @user.save
          BestInPlace.skip_blur  = true
        end

        after(:each) do
          BestInPlace.skip_blur = @old_skip_blur
        end

        it 'should override blur globally' do
          nk = Nokogiri::HTML.parse(helper.best_in_place(@user, :name))
          expect(nk.css("span").attribute("data-bip-skip-blur").value).to eq("true")
        end

        it 'should use helper params' do
          nk = Nokogiri::HTML.parse(helper.best_in_place(@user, :name, skip_blur: false))
          expect(nk.css("span").attribute("data-bip-skip-blur")).to be_nil
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
          expect(span.text).to eq("Lucia")
        end

        context "when the options parameter is left off" do
          it "should call best_in_place with the rest of the parameters and empty options" do
            expect(helper).to receive(:best_in_place).with(@user, :name, {})
            helper.best_in_place_if @condition, @user, :name
          end
        end

        context "when the options parameter is included" do
          it "should call best_in_place with the rest of the parameters" do
            expect(helper).to receive(:best_in_place).with(@user, :name, @options)
            helper.best_in_place_if @condition, @user, :name, @options
          end
        end
      end

      context "when the condition is false" do
        before {@condition = false}

        it "should work with array-like objects in order to provide support to namespaces" do
          expect(helper.best_in_place_if(@condition, [:admin, @user], :name)).to eq "Lucia"
        end

        it "should return the value of the field when the options value is left off" do
          expect(helper.best_in_place_if(@condition, @user, :name)).to eq "Lucia"
        end

        it "should return the value of the field when the options value is included" do
          expect(helper.best_in_place_if(@condition, @user, :name, @options)).to eq "Lucia"
        end
      end
    end
  end
end

# Best In Place
[![Build Status](https://secure.travis-ci.org/bernat/best_in_place.png)](http://travis-ci.org/bernat/best_in_place)
**The Unobtrusive in Place editing solution**


##Description

**Best in Place** is a jQuery based AJAX Inplace-Editor that takes profit of RESTful server-side controllers to allow users to edit stuff with
no need of forms. If the server have standard defined REST methods, particularly those to UPDATE your objects (HTTP PUT), then by adding the
Javascript file to the application it is making all the fields with the proper defined classes to become user in-place editable.

The editor works by PUTting the updated value to the server and GETting the updated record afterwards to display the updated value.

[**SEE DEMO**](http://bipapp.heroku.com/)

---

##Features

- Compatible with text **inputs**
- Compatible with **textarea**
- Compatible with **select** dropdown with custom collections
- Compatible with custom boolean values (same usage of **checkboxes**)
- Sanitize HTML and trim spaces of user's input on user's choice
- Displays server-side **validation** errors
- Allows external activator
- ESC key destroys changes (requires user confirmation)
- Autogrowing textarea
- Helper for generating the best_in_place field only if a condition is satisfied
- Provided test helpers to be used in your integration specs
- Custom display methods

##Usage of Rails 3 Gem

###best_in_place
**best_in_place object, field, OPTIONS**

Params:

- **object** (Mandatory): The Object parameter represents the object itself you are about to modify
- **field** (Mandatory): The field (passed as symbol) is the attribute of the Object you are going to display/edit.

Options:

- **:type** It can be only [:input, :textarea, :select, :checkbox] or if undefined it defaults to :input.
- **:collection**: In case you are using the :select type then you must specify the collection of values it takes. In case you are
  using the :checkbox type you can specify the two values it can take, or otherwise they will default to Yes and No.
- **:path**: URL to which the updating action will be sent. If not defined it defaults to the :object path.
- **:nil**: The nil param defines the content displayed in case no value is defined for that field. It can be something like "click me to edit".
  If not defined it will show *"-"*.
- **:activator**: Is the DOM object that can activate the field. If not defined the user will making editable by clicking on it.
- **:sanitize**: True by default. If set to false the input/textarea will accept html tags.
- **:html_attrs**: Hash of html arguments, such as maxlength, default-value etc.
- **:inner_class**: Class that is set to the rendered form.
- **:display_as**: A model method which will be called in order to display
  this field.

###best_in_place_if
**best_in_place_if condition, object, field, OPTIONS**

It allows us to use best_in_place only if the first new parameter, a
condition, is satisfied. Specifically:

* Will show a normal best_in_place if the condition is satisfied
* Will only show the attribute from the instance if the condition is not satisfied

Say we have something like

    <%= best_in_place_if condition, @user, :name, :type => :input %>

In case *condition* is satisfied, the outcome will be just the same as:

    <%= best_in_place @user, :name, :type => :input %>

Otherwise, we will have the same outcome as:

    <%= @user.name %>

It is a very useful feature to use with, for example, [Ryan Bates](https://github.com/ryanb)' [CanCan](https://github.com/ryanb/cancan), so we only allow BIP edition if the current user has permission to do it.

---

##TestApp and examples
A [test_app](https://github.com/bernat/best_in_place/tree/master/test_app) was created, and can be seen in action in a [running demo on heroku](http://bipapp.heroku.com).

Examples (code in the views):

### Input

    <%= best_in_place @user, :name, :type => :input %>

    <%= best_in_place @user, :name, :type => :input, :nil => "Click me to add content!" %>

### Textarea

    <%= best_in_place @user, :description, :type => :textarea %>

### Select

    <%= best_in_place @user, :country, :type => :select, :collection => [[1, "Spain"], [2, "Italy"], [3, "Germany"], [4, "France"]] %>

Of course it can take an instance or global variable for the collection, just remember the structure `[[key, value], [key, value],...]`.
The key can be a string or an integer.

### Checkbox

    <%= best_in_place @user, :receive_emails, :type => :checkbox, :collection => ["No, thanks", "Yes, of course!"] %>

The first value is always the negative boolean value and the second the positive. Structure: `["false value", "true value"]`.
If not defined, it will default to *Yes* and *No* options.

## Controller response and respond_with_bip

Your controller should respond to json as it's the format used by best in
place javascript. A simple example would be:

    class UserController < ApplicationController
      def update
        @user = User.find(params[:id])

        respond_to do |format|
          if @user.update_attributes(params[:user])
            format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
            format.json { head :ok }
          else
            format.html { render :action => "edit" }
            format.json { render :json => @user.errors.full_messages, :status => :unprocessable_entity }
          end
        end
      end
    end

If you respond with a json like `{:display_as => "New value to show"}` with
status 200 (ok), then the updated field will show *New value to show* after
being updated. This is needed in order to support the custom display methods,
and it's automatically handled if you use the new method to encapsulate
the responses:


        respond_to do |format|
          if @user.update_attributes(params[:user])
            format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
            format.json { respond_with_bip(@user) }
          else
            format.html { render :action => "edit" }
            format.json { respond_with_bip(@user) }
          end
        end

This will be exactly the same as the previous example, but with support to
handle custom display methods.

##Using custom display methods

As of best in place 1.0.3 you can use custom methods in your model in order to
decide how a certain field has to be displayed. You can write something like:

    = best_in_place @user, :description, :type => :textarea, :display_as => :mk_description

Then instead of using `@user.description` to show the actual value, best in
place will call `@user.mk_description`. This can be used for any kind of
custom formatting, text with markdown, currency values, etc...

Because best in place has no way to call that method in your model from
javascript after a successful update, the only way to display the new correct
value after an edition is to use the provided methods to respond in your
controllers, or implement the same in your own way.

If you respond a successful update with a json having a `display_as` key, that
value will be used to update the value in the view. The provided
`respond_with_bip` handles this for you, but if you want you can always
customize this behaviour.


##Non Active Record environments
We are not planning to support other ORMs apart from Active Record, at least for now. So, you can perfectly consider the following workaround as *the right way* until a specific implementation is done for your ORM.

Best In Place automatically assumes that Active Record is the ORM you are using. However, this might not be your case, as you might use another ORM (or not ORM at all for that case!). Good news for you: even in such situation Best In Place can be used!

Let's setup an example so we can illustrate how to use Best In Place too in a non-ORM case. Imagine you have an awesome ice cream shop, and you have a model representing a single type of ice cream. The IceCream model has a name, a description, a... nevermind. The thing is that it also has a stock, which is a combination of flavour and size. A big chocolate ice cream (yummy!), a small paella ice cream (...really?), and so on. Shall we see some code?

    class IceCream < ActiveRecord::Base
      serialize :stock, Hash

      # consider the get_stock and set_stock methods are already defined
    end

Imagine we want to have a grid showing all the combinations of flavour and size and, for each combination, an editable stock. Since the stock for a flavour and a size is not a single and complete model attribute, we cannot use Best In Place *directly*. But we can set it up with an easy workaround.

In the view, we'd do:

    // @ice_cream is already available
    - flavours = ... // get them somewhere
    - sizes = ... // get them somewhere
    %table
      %tr
        - ([""] + flavours).each do |flavour|
          %th= flavour
      - sizes.each do |size|
        %tr
          %th= size
          - flavours.each do |flavour|
            - v = @ice_cream.get_stock(:flavour => flavour, :size => size)
            %td= best_in_place v, :to_i, :type => :input, :path => set_stock_ice_cream_path(:flavour => flavour, :size => size)

Now we need a route to which send the stock updates:

    TheAwesomeIceCreamShop::Application.routes.draw do
      ...

      resources :ice_creams, :only => :none do
        member do
          put :set_stock
        end
      end

      ...
    end

And finally we need a controller:


    class IceCreamsController < ApplicationController::Base
      respond_to :html, :json

      ...

      def set_stock
        flavour = params[:flavour]
        size = params[:size]
        new_stock = (params["fixnum"] || {})["to_i"]

        @ice_cream.set_stock(new_stock, { :flavour => flavour, :size => size })
        if @ice_cream.save
          head :ok
        else
          render :json => @ice_cream.errors.full_messages, :status => :unprocessable_entity
        end
      end

      ...

    end

And this is how it is done!

---

##Test Helpers
Best In Place has also some helpers that may be very useful for integration testing. Since it might very common to test some views using Best In Place, some helpers are provided to ease it.

As of now, a total of four helpers are available. There is one for each of the following BIP types: a plain text input, a textarea, a boolean input and a selector. Its function is to simulate the user's action of filling such fields.

These four helpers are listed below:

* **bip_area(model, attr, new_value)**
* **bip_text(model, attr, new_value)**
* **bip_bool(model, attr)**
* **bip_select(model, attr, name)**

The parameters are defined here (some are method-specific):

* **model**: the model to which this action applies.
* **attr**: the attribute of the model to which this action applies.
* **new_value** (only **bip_area** and **bip_text**): the new value with which to fill the BIP field.
* **name** (only **bip_select**): the name to select from the dropdown selector.

---

##Installation

###Rails 3.1 and higher

Installing *best_in_place* is very easy and straight-forward, even more
thanks to Rails 3.1. Just begin including the gem in your Gemfile:

    gem "best_in_place"

After that, specify the use of the jquery, jquery.purr and best in place
javascripts in your application.js:

    //= require jquery
    //= require jquery.purr
    //= require best_in_place

Then, just add a binding to prepare all best in place fields when the document is ready:

    $(document).ready(function() {
      /* Activating Best In Place */
      jQuery(".best_in_place").best_in_place();
    });

You are done!

###Rails 3.0 and lower

Installing *best_in_place* for Rails 3.0 or below is a little bit
different, since the master branch is specifically updated for Rails
3.1. But don't be scared, you'll be fine!

Rails 3.0 support will be held in the 0.2.X versions, but we have planned not to continue developing for this version of Rails. Nevertheless, you can by implementing what you want and sending us a pull request.

First, add the gem's 0.2 version in the Gemfile:

    gem "best_in_place", "~> 0.2.0"

After that, install and load all the javascripts from the folder
**/public/javascripts** in your layouts. They have to be in the order:

* jquery
* jquery.purr
* **best_in_place**

You can automatize this installation by doing

    rails g best_in_place:setup

Finally, as for Rails 3.1, just add a binding to prepare all best in place fields when the document is ready:

    $(document).ready(function() {
      /* Activating Best In Place */
      jQuery(".best_in_place").best_in_place();
    });

---

## Security

If the script is used with the Rails Gem no html tags will be allowed unless the sanitize option is set to true, in that case only the tags [*b i u s a strong em p h1 h2 h3 h4 h5 ul li ol hr pre span img*] will be allowed. If the script is used without the gem and with frameworks other than Rails, then you should make sure you are providing the csrf authenticity params as meta tags and you should always escape undesired html tags such as script, object and so forth.

    <meta name="csrf-param" content="authenticity_token"/>
    <meta name="csrf-token" content="YOUR UNIQUE TOKEN HERE"/>

---

##TODO

- Client Side Validation definitions
- Accepting more than one handler to activate best_in_place fields

---

## Development

Fork the project on [github](https://github.com/bernat/best_in_place 'bernat / best_in_place on Github')

    $ git clone <<your fork>
    $ cd best_in_place
    $ bundle

### Prepare the test app

    $ cd test_app
    $ bundle
    $ bundle exec rake db:test:prepare
    $ cd ..

### Run the specs

    $ bundle exec rspec spec/

### Bundler / gem troubleshooting

- make sure you've run the bundle command for both the app and test_app!
- run bundle update <<gem name> (in the right place) for any gems that are causing issues

---

##Changelog

###Master branch (and part of the Rails 3.0 branch)
- v.0.1.0 Initial commit
- v.0.1.2 Fixing errors in collections (taken value[0] instead of index) and fixing test_app controller responses
- v.0.1.3 Bug in Rails Helper. Key wrongly considered an Integer.
- v.0.1.4 Adding two new parameters for further customization urlObject and nilValue and making input update on blur.
- v.0.1.5 **Attention: this release is not backwards compatible**. Changing params from list to option hash, helper's refactoring,
  fixing bug with objects inside namespaces, adding feature for passing an external activator handler as param. Adding feature
  of key ESCAPE for destroying changes before they are made permanent (in inputs and textarea).
- v.0.1.6-0.1.7 Avoiding request when the input is not modified and allowing the user to not sanitize input data.
- v.0.1.8 jslint compliant, sanitizing tags in the gem, getting right csrf params, controlling size of textarea (elastic script, for autogrowing textarea)
- v.0.1.9 Adding elastic autogrowing textareas
- v.1.0.0 Setting RSpec and Capybara up, and adding some utilities. Mantaining some HTML attributes. Fix a respond_with bug (thanks, @moabite). Triggering ajax:success when ajax call is complete (thanks, @indrekj). Setting up Travis CI. Updated for Rails 3.1.
- v.1.0.1 Fixing a double initialization bug
- v.1.0.2 New bip_area text helper to work with text areas.
- v.1.0.3 replace apostrophes in collection with corresponding HTML entity,
  thanks @taavo. Implemented `:display_as` option and adding
  `respond_with_bip` to be used in the controller.

###Rails 3.0 branch only
- v.0.2.0 Added RSpec and Capybara setup, and some tests. Fix countries map syntax, Allowing href and some other HTML attributes. Adding Travis CI too. Added the best_in_place_if option. Added ajax:success trigger, thanks to @indrekj.
- v.0.2.1 Fixing double initialization bug.
- v.0.2.2 New bip_area text helper.

---

##Authors, License and Stuff

Code by [Bernat Farrero](http://bernatfarrero.com) from [Itnig Web Services](http://itnig.net) (it was based on the [original project](http://github.com/janv/rest_in_place/) of Jan Varwig) and released under [MIT license](http://www.opensource.org/licenses/mit-license.php).

Many thanks to the contributors: [Roger Campos](http://github.com/rogercampos), [Jack Senechal](https://github.com/jacksenechal) and [Albert Bellonch](https://github.com/albertbellonch).

# Best In Place
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

---

##Usage of Rails 3 Gem

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


I created a [test_app](https://github.com/bernat/best_in_place/tree/master/test_app) and a running demo in heroku to test the features.

Examples (code in the views):

### Input

    <%= best_in_place @user, :name, :type => :input %>

    <%= best_in_place @user, :name, :type => :input, :nil => "Click me to add content!" %>

### Textarea

    <%= best_in_place @user, :description, :type => :textarea %>

### Select

    <%= best_in_place @user, :country, :type => :select, :collection => [[1, "Spain"], [2, "Italy"], [3, "Germany"], [4, "France"]] %>

Of course it can take an instance or global variable for the collection, just remember the structure [[key, value], [key, value],...].
The key can be a string or an integer.

### Checkbox

    <%= best_in_place @user, :receive_emails, :type => :checkbox, :collection => ["No, thanks", "Yes, of course!"] %>

The first value is always the negative boolean value and the second the positive. Structure: ["false value", "true value"].
If not defined, it will default to *Yes* and *No* options.

### Display server validation errors

If you are using a Rails application, your controller's should respond to json in case of error.
Example:

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

At the same time, you must define the restrictions, validations and error messages in the model, as the example below:

    class User < ActiveRecord::Base
      validates :name,
        :length => { :minimum => 2, :maximum => 24, :message => "has invalid length"},
        :presence => {:message => "can't be blank"}
      validates :last_name,
        :length => { :minimum => 2, :maximum => 24, :message => "has invalid length"},
        :presence => {:message => "can't be blank"}
      validates :address,
        :length => { :minimum => 5, :message => "too short length"},
        :presence => {:message => "can't be blank"}
      validates :email,
        :presence => {:message => "can't be blank"},
        :format => {:with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "has wrong email format"}
      validates :zip, :numericality => true, :length => { :minimum => 5 }
    end

When the user tries to introduce invalid data, the error messages defined in the model will be displayed in pop-up windows using the jQuery.purr plugin.

---

##Installation

First add it to your Gemfile:
    gem "best_in_place"

It works by simply adding it to your application.js
    //= require jquery
    //= require best_in_place

To be able to use the script the following block must be added as well:

    $(document).ready(function() {
      /* Activating Best In Place */
      jQuery(".best_in_place").best_in_place()
    });

----

## Security

If the script is used with the Rails Gem no html tags will be allowed unless the sanitize option is set to true, in that case only the tags [*b i u s a strong em p h1 h2 h3 h4 h5 ul li ol hr pre span img*] will be allowed. If the script is used without the gem and with frameworks other than Rails, then you should make sure you are providing the csrf authenticity params as meta tags and you should always escape undesired html tags such as script, object and so forth.

    <meta name="csrf-param" content="authenticity_token"/>
    <meta name="csrf-token" content="YOUR UNIQUE TOKEN HERE"/>

##TODO

- Client Side Validation definitions
- Accepting more than one handler to activate best_in_place fields
- Specs *(sacrilege!!)*

---

##Changelog

- v.0.1.0 Initial deploy
- v.0.1.2 Fixing errors in collections (taken value[0] instead of index) and fixing test_app controller responses
- v.0.1.3 Bug in Rails Helper. Key wrongly considered an Integer.
- v.0.1.4 Adding two new parameters for further customization urlObject and nilValue and making input update on blur.
- v.0.1.5 **Attention: this release is not backwards compatible**. Changing params from list to option hash, helper's refactoring,
  fixing bug with objects inside namespaces, adding feature for passing an external activator handler as param. Adding feature
  of key ESCAPE for destroying changes before they are made permanent (in inputs and textarea).
- v.0.1.6-0.1.7 Avoiding request when the input is not modified and allowing the user to not sanitize input data.
- v.0.1.8 jslint compliant, sanitizing tags in the gem, getting right csrf params, controlling size of textarea (elastic script, for autogrowing textarea)

##Authors, License and Stuff

Code by [Bernat Farrero](http://bernatfarrero.com) from [Itnig Web Services](http://itnig.net) (it was based on the [original project](http://github.com/janv/rest_in_place/) of Jan Varwig) and released under [MIT license](http://www.opensource.org/licenses/mit-license.php).

Many thanks to the contributors: [Roger Campos](http://github.com/rogercampos) and [Jack Senechal](https://github.com/jacksenechal)

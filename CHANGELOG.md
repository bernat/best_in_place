#Changelog
- v.6.1.0
- Version set to the version of rails it matches to (given that is the usecase)

- v.3.1.1
  - Chore/improve readme
  - Upgrade PhantomJS version for travis and remove deprecation warning
  - Add Tests in Rails 5+
  - Bump ruby version support
  - Fix markdown rendering of headings
  - Fix README markdown preview
  - Add a best_in_place:before-update event
  - add option[:skip_blur] to play nice with wysiwhtml5

- v.3.0.3 :
  - Pass all callback arguments on $.ajax

- v.3.0.0 :
  - Expect syntax for spec
  - Deprecated option[:path] in favor of option[:url]
  - Deprecated option[:nil] in favor of option[:place_holder]
  - Deprecated option[:classes] in favor of option[:class]
  - Deprecated opts[:object_name] in favor of option[:as]
  - Deprecated opts[:use_confirm] in favor of option[:confirm]
  - Deprecated Elastic jQuery plugin in favor of jQuery Autosize
  - Fixed bug in jquery.purr
  - Support all supported version of actionpack/rails
  - Dropped dependency on jquery gem
  - Namespaced all data attributes to avoid conflict.
  - Jquery-ui datepicker was extracted to best_in_place.jquery-ui.js
  - Added BestInPlaceEditor.defaults
  - Deprecated opts[:sanitize] in favor of option[:raw]
  - You have to require jquery.purr  before best_in_place.purr
  - You have to require jquery-ui.datepicker  before best_in_place.jquery-ui
  - Added opts[:value] to set custom original-value
  - You can override the default container

- v.2x : glitch in the Matrix

- v.1.1.0 Changed $ by jQuery for compatibility (thanks @tschmitz), new
  events for 'deactivate' (thanks @glebtv), added new 'data' attribute
  the 'path' parameter and some more bugfixes.
  elements to the page (thanks @enriclluelles), added object detection to
  to BIP's span (thanks @straydogstudio), works with dynamically added
- v.1.0.6 Fix issue with display_with. Update test_app to 3.2.
- v.1.0.5 Fix a bug involving quotes (thanks @ygoldshtrakh). Minor fixes
version of Rails before booting. Minor fixes.
  by @bfalling. Add object name option (thanks @nicholassm). Check
- v.1.0.4 Depend on ActiveModel instead of ActiveRecord (thanks,
display_with.
  @skinnyfit). Added date type (thanks @taavo). Added new feature:
- v.1.0.3 replace apostrophes in collection with corresponding HTML entity,
  `respond_with_bip` to be used in the controller.
  thanks @taavo. Implemented `:display_as` option and adding
- v.1.0.2 New bip_area text helper to work with text areas.
- v.1.0.1 Fixing a double initialization bug
- v.1.0.0 Setting RSpec and Capybara up, and adding some utilities. Mantaining some HTML attributes. Fix a respond_with bug (thanks, @moabite). Triggering ajax:success when ajax call is complete (thanks, @indrekj). Setting up Travis CI. Updated for Rails 3.1.

- v.0.2.2 New bip_area text helper.
- v.0.2.1 Fixing double initialization bug.
- v.0.2.0 Added RSpec and Capybara setup, and some tests. Fix countries map syntax, Allowing href and some other HTML attributes. Adding Travis CI too. Added the best_in_place_if option. Added ajax:success trigger, thanks to @indrekj.

- v.0.1.9 Adding elastic autogrowing textareas
- v.0.1.8 jslint compliant, sanitizing tags in the gem, getting right csrf params, controlling size of textarea (elastic script, for autogrowing textarea)
- v.0.1.6-0.1.7 Avoiding request when the input is not modified and allowing the user to not sanitize input data.
- v.0.1.5 **Attention: this release is not backwards compatible**. Changing params from list to option hash, helper's refactoring,
  of key ESCAPE for destroying changes before they are made permanent (in inputs and textarea).
  fixing bug with objects inside namespaces, adding feature for passing an external activator handler as param. Adding feature
- v.0.1.4 Adding two new parameters for further customization urlObject and nilValue and making input update on blur.
- v.0.1.3 Bug in Rails Helper. Key wrongly considered an Integer.
- v.0.1.2 Fixing errors in collections (taken value[0] instead of index) and fixing test_app controller responses
- v.0.1.0 Initial commit

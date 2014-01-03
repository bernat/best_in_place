/**
 * jquery.purr.js
 * Copyright (c) 2008 Net Perspective (net-perspective.com)
 * Licensed under the MIT License (http://www.opensource.org/licenses/mit-license.php)
 *
 * @author R.A. Ray
 * @projectDescription  jQuery plugin for dynamically displaying unobtrusive messages in the browser. Mimics the behavior of the MacOS program "Growl."
 * @version 0.1.0
 *
 * @requires jquery.js (tested with 1.2.6)
 *
 * @param fadeInSpeed           int - Duration of fade in animation in miliseconds
 *                          default: 500
 *  @param fadeOutSpeed         int - Duration of fade out animationin miliseconds
                            default: 500
 *  @param removeTimer          int - Timeout, in miliseconds, before notice is removed once it is the top non-sticky notice in the list
                            default: 4000
 *  @param isSticky             bool - Whether the notice should fade out on its own or wait to be manually closed
                            default: false
 *  @param usingTransparentPNG  bool - Whether or not the notice is using transparent .png images in its styling
                            default: false
 */

(function(jQuery) {

  jQuery.purr = function(notice, options)
  {
    // Convert notice to a jQuery object
    notice = jQuery(notice);

    // Add a class to denote the notice as not sticky
    notice.addClass('purr');

    // Get the container element from the page
    var cont = document.getElementById('purr-container');

    // If the container doesn't yet exist, we need to create it
    if (!cont)
    {
      cont = '<div id="purr-container"></div>';
    }

    // Convert cont to a jQuery object
    cont = jQuery(cont);

    // Add the container to the page
    jQuery('body').append(cont);

    notify();

    function notify ()
    {
      // Set up the close button
      var close = document.createElement('a');
      jQuery(close).attr({
          className: 'close',
          href: '#close'
          }).appendTo(notice).click(function() {
              removeNotice();
              return false;
          });

      // If ESC is pressed remove notice
      jQuery(document).keyup(function(e) {
        if (e.keyCode === 27) {
          removeNotice();
        }
      });

      // Add the notice to the page and keep it hidden initially
      notice.appendTo(cont).hide();

      //Fade in the notice we just added
      notice.fadeIn(options.fadeInSpeed);

      // Set up the removal interval for the added notice if that notice is not a sticky
      if (!options.isSticky)
      {
        var topSpotInt = setInterval(function() {
          // Check to see if our notice is the first non-sticky notice in the list
          if (notice.prevAll('.purr').length === 0)
          {
            // Stop checking once the condition is met
            clearInterval(topSpotInt);

            // Call the close action after the timeout set in options
            setTimeout(function() {
                removeNotice();
              }, options.removeTimer);
          }
        }, 200);
      }
    }

    function removeNotice()
    {
      // Fade the object out before reducing its height to produce the sliding effect
      notice.animate({ opacity: '0' },
        {
          duration: options.fadeOutSpeed,
          complete: function ()
            {
              notice.animate({ height: '0px' },
                {
                  duration: options.fadeOutSpeed,
                  complete: function()
                    {
                      notice.remove();
                    }
                }
              );
            }
        }
      );
    };
  };

  jQuery.fn.purr = function(options)
  {
    options = options || {};
    options.fadeInSpeed = options.fadeInSpeed || 500;
    options.fadeOutSpeed = options.fadeOutSpeed || 500;
    options.removeTimer = options.removeTimer || 4000;
    options.isSticky = options.isSticky || false;
    options.usingTransparentPNG = options.usingTransparentPNG || false;

    this.each(function()
      {
        new jQuery.purr( this, options );
      }
    );

    return this;
  };
})( jQuery );

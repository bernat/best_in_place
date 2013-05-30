// remove default datepicker event
jQuery(document).off('best_in_place:datepicker');

jQuery(document).on('best_in_place:datepicker', function(event, bip, element) {
  // Display the jQuery UI datepicker popup
  jQuery(element).find('input')
    .datepicker({
      format: element.data('date-format')
    })
    .on('hide', function(){
        bip.update();
    })
    .on('changeDate', function(){
        $(this).datepicker('hide');
    })
    .datepicker('show');
});

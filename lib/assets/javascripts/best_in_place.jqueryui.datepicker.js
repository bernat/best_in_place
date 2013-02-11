jQuery(document).on('best_in_place:datepicker', function(event, bip, element) {
  // Display the jQuery UI datepicker popup
  jQuery(element).find('input')
    .datepicker({
      dateFormat: element.data('date-format'),
      onClose: function() {
        bip.update();
      }
    })
    .datepicker('show');
});

// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require_tree .
//= require jquery
//= require jquery_ujs
//= require cocoon
//= require toastr
//= require bootstrap
//= require jquery-ui/core
//= require jquery-ui/widget
//= require jquery-ui/position
//= require jquery-ui/widgets/tooltip
//= require popper
//= require download
//= require chart_with_error_bar


/* Global toastr options */
toastr.options = {
  "closeButton": true,
  "debug": true,
  "newestOnTop": false,
  "progressBar": false,
  "preventDuplicates": true,
  "positionClass": "toast-top-left",
  "onclick": null,
  "showDuration": "100",
  "hideDuration": "100",
  "timeOut": "2000",
  "extendedTimeOut": "1000",
  "showEasing": "linear",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

$( function() {
  // init jQueryUI tooltips
  $( document ).tooltip();

  // init Bootstrap popovers
  $('[data-toggle="popover"]').popover({
    html: true,
    content: function() {
      return $('#popover-content').html();
    }
  });

  // hide popovers on mouseleave
  $('body').on('mouseleave', '.popover', function (e) {
    $(this).hide();
  });

});
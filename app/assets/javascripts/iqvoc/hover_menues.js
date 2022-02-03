(function($) {
  "use strict";

  $(function() {
    $('ul.navbar-nav li.dropdown').hover(function() {
      $(this).find('.dropdown-menu').stop(true, true).delay(100).show();
      $(this).find('> .nav-link').addClass('hover')
    }, function() {
      $(this).find('.dropdown-menu').stop(true, true).delay(100).hide();
      $(this).find('> .nav-link').removeClass('hover')
    });
  });

}(jQuery));

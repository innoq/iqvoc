IQVOC.debounce = (function ($) {

  var debounce = function(fn, delay) {
    var timer;
    return function() {
      var self = this;
      var args = arguments;
      if(timer) {
        clearTimeout(timer);
        timer = null;
      }
      timer = setTimeout(function() {
        fn.apply(self, args);
        timer = null;
      }, delay);
    };
  };

  return debounce;

}(jQuery));

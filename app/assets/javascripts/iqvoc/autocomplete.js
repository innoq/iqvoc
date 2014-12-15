IQVOC.autocomplete = (function($) {

// `field` is the input field to be augmented
// `source` is a function expected to calculate the results - it is invoked with
// the respective query string and a callback and expected to invoke that
// callback with an array of `{ value, label }` objects
// TODO: built-in support for loading indicator?
function augment(field, source) {
  field = field.jquery ? field : $(field);

  field.typeahead({
    minLength: 3,
    highlight: true
  }, {
    source: source,
    templates: {
      empty: function() {
        var el = $("<p />").text("nothing to see, move along");
        return $("<div />").append(el).html();
      },
      suggestion: function(item) {
        var el = $("<p />").text(item.label);
        return $("<div />").append(el).html();
      }
    }
  });
}

return augment;

}(jQuery));

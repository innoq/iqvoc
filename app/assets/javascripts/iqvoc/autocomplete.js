IQVOC.autocomplete = (function($) {

// `field` is the input field to be augmented
// `source` is a function expected to calculate the results - it is invoked with
// the respective query string and a callback and expected to invoke that
// callback with an array of `{ value, label }` objects
// `options` is an object with optional members `noResultsMsg`
// TODO: built-in support for loading indicator?
function augment(field, source, options) {
  field = field.jquery ? field : $(field);
  options = options || {};
  options.noResultsMsg = options.noResultsMsg || "no results";

  field.typeahead({
    minLength: 3,
    highlight: true
  }, {
    source: source,
    displayKey: "label",
    templates: {
      empty: function() {
        var el = $("<p />").text(options.noResultsMsg);
        return $("<div />").append(el).html();
      },
      suggestion: function(item) {
        var el = $("<p />").text(item.label);
        return $("<div />").append(el).html();
      }
    }
  }).bind('typeahead:selected', function(ev, selected, name) {
    if (options.onSelect) {
      options.onSelect(ev, this, selected);
    }
  });
}

return augment;

}(jQuery));

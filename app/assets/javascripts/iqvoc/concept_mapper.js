/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

IQVOC.ConceptMapper = (function($) {

"use strict";

// `selector` is either a jQuery object, a DOM node or a string
function ConceptMapper(selector) {
  if(arguments.length === 0) { // subclassing
    return;
  }

  this.root = selector.jquery ? selector : $(selector);
  this.matchTypes = this.determineMatchTypes();

  var matchOptions = $.map(this.matchTypes, function(desc, id) {
    return $("<option />").val(id).text(desc)[0];
  });

  // spawn UI elements

  this.input = $("<input />").prependTo(this.root);
  $("<button />").text("✓").insertAfter(this.input).
      click($.proxy(this, "onConfirm"));
  this.matchType = $("<select />").append(matchOptions).insertAfter(this.input);
}
ConceptMapper.prototype.delimiter = ", ";
ConceptMapper.prototype.onConfirm = function(ev) {
  ev.preventDefault();

  var textAreaName = this.matchType.val();
  var textArea = document.getElementsByName(textAreaName)[0];
  textArea = $(textArea);

  var newURI = this.input.val();
  var newValue = $.trim(textArea.val() + this.delimiter + newURI);

  textArea.val(newValue);
  this.input.val("");
  this.root.trigger("concept-mapped", {
    uri: newURI,
    matchType: this.matchTypes[textAreaName],
    source: "foo" // TODO
  });
};
ConceptMapper.prototype.determineMatchTypes = function() {
  var data = {};
  $("label", this.root).each(function(i, node) {
    var el = $(node);
    var fieldName = el.attr("for");
    data[fieldName] = el.text();
  });
  return data;
};

return ConceptMapper;

}(jQuery));

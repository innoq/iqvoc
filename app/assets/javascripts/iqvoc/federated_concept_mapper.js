/*jslint vars: true, white: true */
/*global jQuery, IQVOC */

(function($) {

  "use strict";

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
  
    this.container = $("<div />").addClass("concept-mapper control-group");
  
    this.bootstrapInputGroup = $('<div class="input-group" />');
    this.indicator = $('<div class="indicator input-group-append" />');
  
    this.input = this.bootstrapInputGroup
                    .append($("<input />").attr("type", "text").addClass("form-control"))
                    .append(this.indicator)
                    .prependTo(this.container);
  
    $("<button />").addClass("btn btn-outline-secondary fa fa-plus").
        insertAfter(this.input).click($.proxy(this, "onConfirm"));
  
    this.matchType = $("<select />").addClass("form-control")
                      .append(matchOptions)
                      .insertAfter(this.input);
  
    this.container.appendTo(this.root);
  }

  ConceptMapper.prototype.delimiter = ", ";

  ConceptMapper.prototype.onConfirm = function(ev) {
    ev.preventDefault();
  
    var textAreaName = this.matchType.val();
    var textArea = document.getElementsByName(textAreaName)[0];
    textArea = $(textArea);
  
    // FIXME: last input the correct one
    var newURI = $(this.input.find('input')[1]).val();
    var newValue = $.trim(textArea.val() + this.delimiter + newURI);
  
    textArea.val(newValue);
    this.input.find('input').val("");
    this.root.trigger("concept-mapped", {
      uri: newURI,
      matchType: this.matchTypes[textAreaName]
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

  // `selector` is either a jQuery object, a DOM node or a string
  function FederatedConceptMapper(selector) {
    ConceptMapper.apply(this, arguments);

    var sources = this.root.data("datasets");
    if(!sources) { // fall back to non-federated base class only
      return;
    }
    sources["_custom"] = this.root.data("translation-other");

    sources = $.map(sources, function(name, url) {
      return $("<option />").val(url).text(name)[0];
    });
    this.source = $("<select />").addClass("form-control").append(sources).
        insertBefore(this.input);

    this.indicator.append($('<span class="input-group-text" />')
      .append('<i class="fa fa-refresh fa-spin" />'));

    var self = this;
    var input = this.input.find("input")

    IQVOC.autocomplete(input, IQVOC.debounce($.proxy(this, "onChange"), 500), {
      noResultsMsg: this.root.data("no-results-msg"),
    });

  }

  FederatedConceptMapper.prototype = new ConceptMapper();

  FederatedConceptMapper.prototype.onChange = function(query, callback) {
    var self = this;

    self.indicator.addClass("active");

    $.ajax({
      type: "GET",
      url: this.root.data("remote-proxy-url"),
      data: {
        prefix: encodeURIComponent(query), // FIXME: (double-)encoding should not be necessary
        dataset: this.source.find("option:selected").text(),
        layout: 0
      },
      success: function() {
        // inject callback
        var args = Array.prototype.slice.apply(arguments);
        args.push(callback);
        return self.onResults.apply(self, args);
      },
      complete: function() {
        self.indicator.removeClass("active");
      }
    });
  };

  FederatedConceptMapper.prototype.onResults = function(html, status, xhr, callback) {
    var doc = $("<div />").append(html);
    var concepts = doc.find(".concept-item-link");
    var items = $.map(concepts, function(node, i) {
      var el = $(node);
      return { label: el.text(), value: el.data("resource-url") };
    });
    callback(items);
  };

  $(function() {
    // init
    new FederatedConceptMapper(".matches");
  });

}(jQuery));

// EntitySelector extension for qualified entities

/*jslint vars: true, unparam: true, white: true */
/*global jQuery, IQVOC */

(function($) {
  "use strict";

  var QualifiedEntitySelector = function(args) {
    var res = IQVOC.EntitySelector.apply(this, arguments);
    if(this.qualified()) {
      this.container.on("change", "input.qualified", this.onQualify);
    }
    return res;
  };

  QualifiedEntitySelector.prototype = new IQVOC.EntitySelector();

  QualifiedEntitySelector.prototype.qualified = function() { // TODO: document (NB: doubles as i18n)
    return this.el.data("qualified") || false;
  };

  QualifiedEntitySelector.prototype.onQualify = function(ev) {
    var el = $(this),
      entity = el.closest("li"),
      widget = el.closest(".entity_select").data("widget"),
      id = entity.data("id"),
      value = id + ":" + el.val();
    widget.remove(id);
    widget.add(value);
  };

  QualifiedEntitySelector.prototype.createEntity = function(entity) {
    var node = IQVOC.EntitySelector.prototype.createEntity.apply(this, arguments),
      qualified = this.qualified();
    if(qualified) {
      var el = $(node);
      $('<input class="qualified" />').attr("placeholder", qualified).
          val(entity[qualified]).insertAfter(el.children(":first"));
    }
    return node;
  };

  $(function() {
    // init entity selection (edit mode)
    $("input.entity_select").each(function(i, node) {
      new QualifiedEntitySelector(node);
    });
  });

}(jQuery));

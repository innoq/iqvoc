IQVOC.createNote = (function ($) {

  var createNote = function(ev) {
    var addButton = $(this);
    var container = addButton.closest("fieldset");
    var source = $("ol li:last-child", container);
    var inputSelector = "input, select, textarea";
  
    if(source.is(":hidden")) {
      source.show();
      return false;
    }
  
    var clone = source.clone();
  
    var count = source.find(inputSelector)[0].id
        .match(/_(\d+)_/)[1];
    count = String(parseInt(count, 10) + 1);
    var newIdCount = "_" + count + "_",
      newNameCount = "[" + count + "]";
  
    clone.find("label").each(function(index, element) {
      var el = $(element);
      if(el.attr("for")) {
        el.attr("for", el.attr("for").replace(/_\d+_/, newIdCount));
      }
    });
  
    clone.find(inputSelector).each(function(index, element) {
      var el = $(element);
      el.val("");
      if(el.attr("id")) {
        el.attr("id", el.attr("id").replace(/_\d+_/, newIdCount));
      }
      if(el.attr("name")) {
        el.attr("name", el.attr("name").replace(/\[\d+\]/, newNameCount));
      }
      if (el.attr('name').match(/\[position\]/)) {
        var lastPos = parseInt(count, 10) || 0;
        el.val(lastPos + 1);
      }
    });
  
    clone.addClass("new");
    $("ol", container).append(clone);
  
    return false;
  };

  return createNote;

}(jQuery));

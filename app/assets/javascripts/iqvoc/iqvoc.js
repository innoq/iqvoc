/*jslint vars: true, unparam: true, browser: true, white: true */
/*global jQuery */

var IQVOC = (function($) {

"use strict";

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
  });

  clone.addClass("new");
  $("ol", container).append(clone);

  return false;
};

// work around apparent capybara-webkit issue:
// https://github.com/thoughtbot/capybara-webkit/issues/43
var Storage = localStorage || null;
if(Storage === null) {
  Storage = {};
  Storage.getItem = function() { return null; };
  Storage.setItem = $.noop;
}

return {
  Storage: Storage,
  createNote: createNote
};

}(jQuery));

jQuery(document).ready(function($) {
  "use strict";

  IQVOC.quicksearch(".quicksearch");

  var locale = document.documentElement.getAttribute("lang");

  // language selection
  $(".dropdown-toggle").click(function(ev) { // use Bootstrap's Dropwdown, but without the side-effects
    $(this).closest(".dropdown").toggleClass("open");
  });
  var langWidget = $("ul.lang-widget")[0];
  // primary language (converting links to radio buttons)
  $("a", langWidget).each(function(i, node) {
    var link = $(node),
      el = link.closest("li"),
      btn = $('<input type="radio" name="primary_language">');
    if(link.hasClass("current")) {
      btn[0].checked = true;
    }
    var label = $("<label />").append(btn).append(link);
    el.append(label);
    return label[0];
  });
  $("input:radio", langWidget).live("change", function(ev) {
    window.location = $(this).closest("label").find("a").attr("href");
  });
  // secondary language
  var toggleSections = function(langSelected) {
    $(".translation[lang]").each(function(i, node) {
      var el = $(node),
        lang = el.attr("lang");
      if(lang && lang !== locale && $.inArray(lang, langSelected) === -1) {
        el.addClass("hidden");
      } else {
        el.removeClass("hidden");
      }
    });
  };
  var updateNoteLangs = function(langSelected) {
    $(".inline_note.new select").each(function(i, sel) { // NB: new notes only!
      $(sel).find("option").each(function(i, opt) {
        var el = $(opt),
          lang = el.val();
        if(lang !== locale && $.inArray(lang, langSelected) === -1) {
          el.remove();
        }
      });
    });
  };
  $(document).bind("lang_selected", function(ev, data) {
    toggleSections(data.langs);
    updateNoteLangs(data.langs);
  });
  var langSelector = new IQVOC.LanguageSelector(langWidget, "lang_selected");
  if($("#new_concept, #edit_concept").length) { // edit mode
    // disable secondary language selection to avoid excessive state complexity
    $(":checkbox", langSelector.container).prop("disabled", true);
  }

  // entity selection (edit mode)
  $("input.entity_select").each(function(i, node) {
    new IQVOC.QualifiedEntitySelector(node);
  });

  // hide broader relations for top+ terms (mutually exclusive in mono hierarchies)
  var topTerm = $("#concept_top_term.exclusive");
  var onTopTermToggle = function(ev) {
    var broader = topTerm.closest(".control-group").next(); // XXX: brittle
    broader[topTerm.prop("checked") ? "slideUp" : "slideDown"]();
  };
  topTerm.on("change", onTopTermToggle);
  onTopTermToggle();

  // Label editing (inline notes)
  $("fieldset.note_relation ol li.inline_note.new").hide();
  $("fieldset.note_relation input[type=button]").click(function(ev) {
    IQVOC.createNote.apply(this, arguments);
    langSelector.notify(); // trigger updateNoteLangs -- XXX: hacky!?
  });
  $("li.inline_note input:checkbox").change(function(ev) {
    var action = this.checked ? "addClass" : "removeClass";
    $(this).closest("li")[action]("deleted");
  });

  // Datepicker
  $.datepicker.setDefaults($.datepicker.regional[locale]);
  $("input.datepicker").datepicker({ dateFormat: "yy-mm-dd" });

  // Dashboard table row highlighting and click handling
  $("tr.highlightable")
    .hover(function(ev) {
      var action = ev.type === "mouseenter" ? "addClass" : "removeClass";
      $(this)[action]("hover");
    })
    .click(function(ev) {
      window.location = $(this).attr("data-url");
    });

  // Search
  $(".checkbox-select-all").click(function() {
    $(this).closest('.controls').find("input:checkbox").attr("checked", true);
  });
  $(".checkbox-select-none").click(function() {
    $(this).closest('.controls').find("input:checkbox").attr("checked", false);
  });
  $("select.search_type").change(function() {
    var result_type_filter = $(".result_type_filter");
    if($(this).val().match(/labeling/)) {
      result_type_filter.show();
    }
    else {
      result_type_filter.hide();
    }
  });
  $("select.search_type").change();

  // hierarchical tree view
  $("ul.hybrid-treeview").each(function() {
    var url = $(this).data('url');
    var container = this;

    var dragabbleSupport = $(container).data('dragabble');
    var polyhierarchySupport = $(container).data('polyhierarchy-support');
    var saveLabel = $(container).data('save-label');
    var copyLabel = $(container).data('copy-label');
    var undoLabel = $(container).data('undo-label');

    // build tree data from html markup
    var data = $(this).children('li').map(function() {
      var item = $(this);
      var hasChildren = item.data('has-children');
      return {
        label: item.children('a').html(),
        load_on_demand: hasChildren,
        id: item.attr('id'),
        url: item.children('a').attr('href')
      };
    });

    $(this).tree({
      dragAndDrop: dragabbleSupport ? true : false,
      autoEscape: false,
      selectable: false,
      closedIcon: $('<i class="fa fa-plus-square-o"></i>'),
      openedIcon: $('<i class="fa fa-minus-square-o"></i>'),
      data: data,
      dataUrl: function(node) {
        return node ? url + '?root=' + node.id : url;
      },
      onCreateLi: function(node, $li) {
        // TODO: add additionalText if present
        var link = $('<a href="' + node.url +'">' + node.name + '</a>');
        $li.find('.jqtree-title').replaceWith(link);

        if (dragabbleSupport) {
          // mark published/unpublished items
          if (typeof node.published != 'undefined' && !node.published) {
            link.addClass('unpublished');
          } else {
            link.addClass('published');
          }

          // mark locked items
          if (typeof node.locked != 'undefined' && node.locked) {
            link.after(' <i class="fa fa-lock"/>');
          } else {
            link.after(' <i class="fa fa-arrows"/>');
          }
        }

        if(node.moved) {
          // TODO: move data-attributes to parent li to be more DRY
          var saveButton = $('<button type="button" class="btn btn-primary btn-xs node-btn" data-node-id="' + node.id + '" data-old-parent-node-id="' + node.old_parent_id +'" data-new-parent-node-id="' + node.target_node_id +'" data-update-url="'+ node.update_url +'" data-tree-action="move"><i class="fa fa-save"></i> ' + saveLabel + '</button>');
          var copyButton = $('<button type="button" class="btn btn-primary btn-xs node-btn" data-node-id="' + node.id + '" data-old-parent-node-id="' + node.old_parent_id +'" data-new-parent-node-id="' + node.target_node_id +'" data-update-url="'+ node.update_url +'" data-tree-action="copy"><i class="fa fa-copy"></i> ' + copyLabel + '</button>');
          var undoButton = $('<button type="button" class="btn btn-primary btn-xs reset-node-btn" data-node-id="' + node.id + '" data-old-parent-node-id="' + node.old_parent_id +'"><i class="fa fa-undo"></i> ' + undoLabel + '</button>');
          link.after(' ', saveButton, ' ', undoButton);

          if(polyhierarchySupport) {
            saveButton.after(' ', copyButton);
          }
        }
      },
      onCanMoveTo: function(moved_node, target_node, position){
        // prevent node movement inside parent node
        if (moved_node.parent === target_node.parent && position === 'after'){
          return false;
        }
        // prevent locked node movement
        else if (moved_node.locked === true || target_node.locked === true) {
          return false;
        }
        // only drop node inside nodes, no ordering
        else if (position === 'after') {
          return false;
        } else {
          return true;
        }
      }
    });
  });

  // mark moved nodes
  $('ul.hybrid-treeview').on('tree.move', function(event) {
    var moved_node = event.move_info.moved_node;
    $(this).tree('updateNode', moved_node, {
      moved: true,
      old_parent_id: moved_node.parent.id,
      target_node_id: event.move_info.target_node.id
    });
  });

  // save/copy moved node
  $('ul.hybrid-treeview').on('click', 'button.node-btn', function(event) {
    var $tree = $('ul.hybrid-treeview');
    var treeAction = $(this).data('tree-action');
    var updateUrl = $(this).data('update-url');

    var movedNodeId = $(this).data('node-id');
    var oldParentNodeId = $(this).data('old-parent-node-id');
    var newParentNodeId = $(this).data('new-parent-node-id');

    console.log('treeAction', treeAction);
    console.log('movedNodeId', movedNodeId);
    console.log('oldParentNode', oldParentNodeId);
    console.log('newParentNode', newParentNodeId);

    $.ajax({
      url : updateUrl,
      type : 'PATCH',
      data : {
        tree_action: treeAction,
        moved_node_id: movedNodeId,
        old_parent_node_id: oldParentNodeId,
        new_parent_node_id: newParentNodeId
      },
      statusCode: {
        200: function() {
          var moved_node = $tree.tree('getNodeById', movedNodeId);
          $tree.tree('updateNode', moved_node, {
            moved: false,
            published: false
          });
        }
      }
    });
  });

  // reset moved node
  // TODO: move to correct old position, currently moved on top
  $('ul.hybrid-treeview').on('click', 'button.reset-node-btn', function(event) {
    var $tree = $('ul.hybrid-treeview');
    var node = $tree.tree('getNodeById', $(this).data('node-id'));
    var targetNode = $tree.tree('getNodeById', $(this).data('old-parent-node-id'));

    $tree.tree('updateNode', node, {moved: false});
    $tree.tree('moveNode', node, targetNode, 'inside');
  });

  // unobtrusive tabs
  $(".tab-panels").addClass("tab-content"); // the latter is for Bootstrap Tabs

  IQVOC.onebox(".onebox");
  new IQVOC.FederatedConceptMapper(".matches");
  // XXX: inelegant
  if($("textarea:first").length) { // edit mode
    new IQVOC.ConceptMappingManager(".matches", true);
  } else { // view mode
    new IQVOC.ConceptMappingManager("#matches", false);
  }

  IQVOC.labelResolver();
  $(document.body).on("concept-label", function(ev, container) {
    IQVOC.labelResolver(container);
  });
});

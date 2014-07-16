/*jslint vars: true, browser: true, white: true */
/*global jQuery, IQVOC */

IQVOC.treeview = (function($) {

"use strict";

function Treeview(container) {
  this.container = container.jquery ? container : $(container);

  $(container).each(function() {
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
        url: item.children('a').attr('href'),
        locked: item.data('top-term') ? true : false
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
}

return function(selector) {
  return new Treeview(selector); // XXX: returning an instance of a private class seems weird
};

}(jQuery));

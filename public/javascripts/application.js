jQuery(document).ready(function() {
  var locale = $("meta[name=i18n-locale]").attr("content");

  // Creates the label_relation widget
  var label_relations = $(".label_relation")
  $.each(label_relations, function(index, value) {
    var name = $(value).attr("name");
    var data_present_relations = $(value).attr("data-present-relations");
    var data_post_url = $(value).attr("data-post-url");
    var data_delete_url = $(value).attr("data-delete-url");
    var data_get_url = $(value).attr("data-get-url");
    var data_branch_url = $(value).attr("data-branch-url");
    var data_token_limit = $(value).attr("data-token-limit");
    var data_auth_token = $(value).attr("data-auth-token");
    var data_show_url = $(value).attr("data-show-url");
    var data_versioned_show_url = $(value).attr("data-versioned-show-url");
    var new_link = $("#new_" + name);
    var new_link_old_value = $("#new_" + name).attr("href");
    $(value).tokenInput(data_get_url, {
      hintText: $(value).attr("data-hint-text"),
      noResultsText: $(value).attr("data-no-results-text"),
      searchingText: $(value).attr("data-searching-text"),
      prePopulate: eval("(" + data_present_relations + ")"),
      tokenLimit: typeof(data_token_limit) !== 'undefined' ? data_token_limit : null,
      branchURL: data_branch_url,
      showURL: data_show_url,
      versionedShowURL: data_versioned_show_url,
      authToken: data_auth_token,
      onDelete: function(token_data) {
        //$.post(data_post_url + '/' + token_data.id, { _method: 'delete' });
        post_data = token_data;
        post_data['_method'] = 'delete'
        $.ajax({
          type: 'POST',
          url: data_delete_url.replace(/ORIGIN/g, token_data.origin),
          data: post_data,
          success: function (data) {
          },
          error:
          function(xhr, status, error) {
            $('html, body').animate({
              scrollTop:0
            }, 'slow');
            xhr.responseText.length > 1 ? $(".ajax_error.flash_error").html(xhr.responseText) : $(".ajax_error.flash_error").html($("body").attr("data-default-ajax-error"));
            $(".ajax_error.flash_error").fadeIn('slow').fadeOut(15000);
          }
        });
      },
      onAdd: function(data) {

        var relation_id = null;
        $.ajax({
          type: 'POST',
          async: false,
          url: data_post_url,
          data: data,
          success: function (data) {
            relation_id = data;
          },
          error:
          function(xhr, status, error) {
            $('html, body').animate({
              scrollTop:0
            }, 'slow');
            xhr.responseText.length > 1 ? $(".ajax_error.flash_error").html(xhr.responseText) : $(".ajax_error.flash_error").html($("body").attr("data-default-ajax-error"));
            $(".ajax_error.flash_error").fadeIn('slow').fadeOut(10000);
          }
        });
        return relation_id;
      },
      onSearch: new_link.length != 0 ? (function(query) {
        query.length == 0 ? new_link.attr("href", new_link_old_value) : new_link.attr("href", new_link_old_value + "?value=" + query);
      }) : null,
            
      classes: {
        tokenList: "token-input-list-iqvoc",
        token: "token-input-token-iqvoc",
        tokenDelete: "token-input-delete-token-iqvoc",
        selectedToken: "token-input-selected-token-iqvoc",
        highlightedToken: "token-input-highlighted-token-iqvoc",
        dropdown: "token-input-dropdown-iqvoc",
        dropdownItem: "token-input-dropdown-item-iqvoc",
        dropdownItem2: "token-input-dropdown-item2-iqvoc",
        selectedDropdownItem: "token-input-selected-dropdown-item-iqvoc",
        inputToken: "token-input-input-token-iqvoc"
      }
    });
  });


	
  // Label editing (inline notes)
  $("fieldset.note_relation ol li.inline_note.new").hide();
	
  $("fieldset.note_relation input[type=button]").click(function() {
    var source = $(this).parent().find("ol li:last-child");
		
    // special case for usage notes
    // a usage note contains a select box instead of a textarea
    var isUsageNote = source.find("label:first").attr("for").match(/^concept_umt_usage_notes/);
		
    if (source.is(":hidden")) {
      source.show();
      return false;
    }
		
    var clone  = source.clone();
		
    if (!isUsageNote) {
      source.find("textarea").attr("id").match(/_(\d)_/);
    }
    else {
      source.find("select").attr("id").match(/_(\d)_/);
    }
		
    var count 		 = parseInt(RegExp.$1) + 1;
		
    var newIdCount 	 = '_' + count + '_';
    var newNameCount = '[' + count + ']';
		
    clone.find("label")
    .attr("for", source.find("label").attr("for").replace(/_\d_/, newIdCount));
			
    clone.find("input")
    .attr("id", source.find("input[type=hidden]").attr("id").replace(/_\d_/, newIdCount))
    .attr("name", source.find("input[type=hidden]").attr("name").replace(/\[\d\]/, newNameCount));
		
    if (!isUsageNote) {
      clone.find("textarea")
      .val("")
      .attr("id", source.find("textarea").attr("id").replace(/_\d_/, newIdCount))
      .attr("name", source.find("textarea").attr("name").replace(/\[\d\]/, newNameCount));
    }
    clone.find("select")
    .attr("id", source.find("select").attr("id").replace(/_\d_/, newIdCount))
    .attr("name", source.find("select").attr("name").replace(/\[\d\]/, newNameCount));

    clone.addClass("new");

    $(this).parent().find("ol").append(clone);

    return false;
  });
	
  // Label editing (inline notes)
  $("li.inline_note input:checkbox").change(function() {
    if (this.checked) {
      $(this).parent().addClass("deleted");
    }
    else {
      $(this).parent().removeClass("deleted");
    }
  });
	
  // Datepicker
  $.datepicker.setDefaults($.datepicker.regional[locale]);
  $("input.datepicker").datepicker();
	
  // Dashboard table row highlighting and click handling
  $("tr.highlightable")
  .hover(
    function() {
      $(this).addClass("hover")
    },
    function() {
      $(this).removeClass("hover")
    }
    )
  .click(
    function() {
      window.location = $(this).attr("data-url")
    }
    );
	
  // Search
  $("button#language_select_all").click(function() {
    $("input[type=checkbox].lang_check").attr("checked", true);
  });
  $("button#language_select_none").click(function() {
    $("input[type=checkbox].lang_check").attr("checked", false);
  });

  // Tree
  var trees = $("ul.treeview");
  $.each(trees, function(index, value) {
    $(value).treeview($.parseJSON($(value).attr("data-remote-settings")));
  });

  $("ul.hybrid-treeview").each(function() {
    var url = $(this).attr("data-url");
    var container = this;
    $(this).treeview({
      collapsed: true,
      toggle: function() {
        var $this = $(this);
        if ($this.hasClass("hasChildren")) {
          var childList = $this.removeClass("hasChildren").find("ul");
          $.fn.treeviewLoad({
            "url": url
          }, this.id, childList, container);
        }
      }
    });
  });

  // New Label (Inflectional search)
  $("form#new_label input#label_value").keyup(function() {
    var notification = $("p.label_warning");
    $.ajax({
      type: 'GET',
      url: $(this).attr("data-remote"),
      dataType: "json",
      data: {
        query: $(this).val()
      },
      success: function (data) {
        if (data) {
          var msg = notification.attr("data-msg");
          notification.html(msg + " " + data.label.value).show();
        }
        else {
          notification.hide();
        }
      }
    });
  });
});

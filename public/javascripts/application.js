jQuery(document).ready(function() {
    var locale = $("html").attr("data-locale");
    //Some click handlers
    $('.new_compound_form').click(function(event) {
        event.preventDefault(); // this prevents the original href of the link from being opened
        $.ajax({
            type: 'POST',
            url: this.href,
            success: function (data) {
                var compound_form_id = data.id;

                var widget = $('.compound_form_widget_hidden').clone();
                widget.removeClass("compound_form_widget_hidden").addClass("compound_form_widget");

                var widget_input = widget.children(".tokenizer_input_wrapper").children("input");
                widget_input.removeClass("compound_form_hidden").addClass("compound_form");
                widget_input.attr("data-compound-form-id", compound_form_id);

                var new_post_url = widget_input.attr("data-post-url").replace(/ID/g, compound_form_id);
                widget_input.attr("data-post-url", new_post_url);

                var widget_delete = widget.children(".tokenizer_delete_wrapper").children("form");
                var new_form_url = widget_delete.attr("action").replace(/ID/g, compound_form_id);
                widget_delete.attr("action", new_form_url);

                var append_container = $(".compound_form_widget:last");
                append_container.length == 0 ? $(".relation-body.compound_forms fieldset").prepend(widget) : $(".compound_form_widget:last").after(widget);

                var inserted_widget_input = $(".compound_form_widget:last").children(".tokenizer_input_wrapper");
                create_compound_form_widget(inserted_widget_input.children("input"));

            },
           error: function(xhr, status, error) {
               $('html, body').animate({scrollTop:0}, 'slow');
               xhr.responseText.length > 1 ? $(".ajax_error.flash_error").html(xhr.responseText) : $(".ajax_error.flash_error").html($("body").attr("data-default-ajax-error"));
               $(".ajax_error.flash_error").fadeIn('slow').fadeOut(10000);
           }
        });
    });

    $('.compound_form_delete').live('click', function(event) {
       event.preventDefault(); // this prevents the original href of the link from being opened
          var form = $(this).parent();
          var url = form.attr("action")
         $.post(url, { _method: 'delete'  }, function(data) {
            form.parent().parent().detach();
          });
    });

	//Creates the label_relation widget
    var label_relations = $(".label_relation")
    $.each(label_relations, function(index, value) {
        var name = $(value).attr("name");
        var data_present_relations = $(value).attr("data-present-relations");
        var data_post_url = $(value).attr("data-post-url");
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
                  $.ajax({
                    type: 'POST',
                    url: data_post_url + '/' + token_data.id,
                    data: {_method: 'delete'},
                    success: function (data) {
                    },
                    error:
                     function(xhr, status, error) {
                        $('html, body').animate({scrollTop:0}, 'slow');
                        xhr.responseText.length > 1 ? $(".ajax_error.flash_error").html(xhr.responseText) : $(".ajax_error.flash_error").html($("body").attr("data-default-ajax-error"));
                        $(".ajax_error.flash_error").fadeIn('slow').fadeOut(15000);
                    }
                });
            },
            onAdd: function(id) {

                var relation_id = null;
                $.ajax({
                    type: 'POST',
                    async: false,
                    url: data_post_url,
                    data: {id: id},
                    success: function (data) {
                    	relation_id = data;
                    },
                    error:
                     function(xhr, status, error) {
                        $('html, body').animate({scrollTop:0}, 'slow');
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
                tokenList: "token-input-list-facebook",
                token: "token-input-token-facebook",
                tokenDelete: "token-input-delete-token-facebook",
                selectedToken: "token-input-selected-token-facebook",
                highlightedToken: "token-input-highlighted-token-facebook",
                dropdown: "token-input-dropdown-facebook",
                dropdownItem: "token-input-dropdown-item-facebook",
                dropdownItem2: "token-input-dropdown-item2-facebook",
                selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
                inputToken: "token-input-input-token-facebook"
            }
        });
    });

    //Creates the compound_forms widget
    var compound_forms = $(".compound_form")

    create_compound_form_widget(compound_forms);

    function create_compound_form_widget(compound_forms) {
    	$.each(compound_forms, function(index, value) {
	        var name = $(value).attr("name");
	        var data_present_relations = $(value).attr("data-present-relations");
	        var data_post_url = $(value).attr("data-post-url");
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
	                $.post(data_post_url + '/' + token_data.id, { _method: 'delete' });
	            },
	            onAdd: function(id) {

	                var relation_id = null;
	                $.ajax({
	                    type: 'POST',
	                    async: false,
	                    url: data_post_url,
	                    data: {id: id},
	                    success: function (data) {
	                    	relation_id = data;
	                    }
	                });
	                return relation_id;
	            },
	            onSearch: new_link.length != 0 ? (function(query) {
	             query.length == 0 ? new_link.attr("href", new_link_old_value) : new_link.attr("href", new_link_old_value + "?value=" + query);
	            }) : null,

	            classes: {
	                tokenList: "token-input-list-facebook",
	                token: "token-input-token-facebook",
	                tokenDelete: "token-input-delete-token-facebook",
	                selectedToken: "token-input-selected-token-facebook",
	                highlightedToken: "token-input-highlighted-token-facebook",
	                dropdown: "token-input-dropdown-facebook",
	                dropdownItem: "token-input-dropdown-item-facebook",
	                dropdownItem2: "token-input-dropdown-item2-facebook",
	                selectedDropdownItem: "token-input-selected-dropdown-item-facebook",
	                inputToken: "token-input-input-token-facebook"
	            }
	        });
	    });
    }

	function rebuildInflectionals() {
		var endings    = $("#label_endings").val();
		var baseForm   = $("#label_base_form").val();
		var target     = $("#label_inflectionals_attributes");
		var inflectionals = [];
		
		endings = endings.split(/\s+|,/);
		
		$.each(endings, function(index, ending){
			if(ending == ".") {
				inflectionals.push(baseForm);
			}
			else {
				inflectionals.push(baseForm + ending);
			}
		});
		
		target.val(inflectionals.join("\n"));
	}
	
	// Observer for generating inflectionals
	$("#label_endings").keyup(function(event) {		
		if (event.keyCode == 32) { // SPACE
			return false;
		}
		
		rebuildInflectionals();
		$("select#label_inflectional_code option[value='']").attr("selected", "selected");
	});
	
	// Observer for generating inflectionals
	$("#label_base_form").keyup(function(){
		rebuildInflectionals();
	});
	
	$("select#label_inflectional_code").change(function() {
		var selected = $(this).find("option:selected");
		$("#label_endings").val(selected.attr("data-endings"));
		rebuildInflectionals();
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
		else {
			clone.find("select")
				.attr("id", source.find("select").attr("id").replace(/_\d_/, newIdCount))
				.attr("name", source.find("select").attr("name").replace(/\[\d\]/, newNameCount));
		}
		
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
			function() { $(this).addClass("hover") },
			function() { $(this).removeClass("hover") }
		)
		.click(
			function() { window.location = $(this).attr("data-url") }
		);
	
	// Search
	// function disableLanguageOptionsForSearch(state) {
	// 	$("button#language_select_all").attr("disabled", state);
	// 	$("button#language_select_none").attr("disabled", state);
	// 	$("input[type=checkbox].lang_check").attr("disabled", state);
	// }
	// 
	// if ($("select[name=type]").val() == "inflectional") {
	// 	disableLanguageOptionsForSearch(true);
	// }
	// 
	// $("select[name=type]").change(function() {
	// 	if ($(this).val() == "inflectional")
	// 		disableLanguageOptionsForSearch(true);
	// 	else
	// 		disableLanguageOptionsForSearch(false);
	// });
	
	$("button#language_select_all").click(function() {
		$("input[type=checkbox].lang_check").attr("checked", true);
	});
	$("button#language_select_none").click(function() {
		$("input[type=checkbox].lang_check").attr("checked", false);
	});
	
	if ($("form").attr("data-type") != "" && $("form").attr("data-type") != "inflectional") {
		$("textarea#query")
			.replaceWith('<input type="text" name="query" id="query" value="' + $("form").attr("data-query") + '">');	
	}
	
	$("select.search_type").change(function() {
		if ($(this).val() != "inflectional") {
			$("textarea#query").replaceWith('<input type="text" name="query" id="query" value="' + $("textarea#query").val() + '">');	
		}
		else {
			$("input#query").replaceWith('<textarea id="query" name="query">' + $("input#query").val().split(" ").join("\n") + '</textarea>');	
		}
	});

    // Tree
    var trees = $("ul.treeview");
    $.each(trees, function(index, value) {
        $(value).treeview($.parseJSON($(value).attr("data-remote-settings")));
    });

	// New Label (Inflectional search)
	$("form#new_label input#label_value").keyup(function() {
		var notification = $("p.label_warning");
		$.ajax({
           	type: 'GET',
           	url: $(this).attr("data-remote"),
			dataType: "json",
			data: { query: $(this).val() },
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

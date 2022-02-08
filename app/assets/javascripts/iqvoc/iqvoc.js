/*jslint vars: true, unparam: true, browser: true, white: true */
/*global jQuery */

window.IQVOC = {};

jQuery(document).ready(function($) {
  "use strict";

  var locale = document.documentElement.getAttribute("lang");

  var langWidget = $("ul.lang-widget")[0];

  if (langWidget) {
    // primary language (converting links to radio buttons)
    $("a", langWidget).each(function(i, node) {
      var link = $(node);
      var el = link.closest("li");
      var btn = $('<input type="radio" name="primary_language">');
      if(link.hasClass("active")) {
        btn[0].checked = true;
      }
      var label = $("<label />").append(btn).append(link);
      el.append(label);
      return label[0];
    });

    $("input:radio", langWidget).on("change", function(ev) {
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
      $(".inline_note.new select[id*=language]").each(function(i, sel) { // NB: new notes only!
        $(sel).find("option").each(function(i, opt) {
          var el = $(opt),
            lang = el.val();
          if(lang !== locale && $.inArray(lang, langSelected) === -1) {
            el.remove();
          }
        });
      });
    };
    $(document).on("lang_selected", function(ev, data) {
      toggleSections(data.langs);
      updateNoteLangs(data.langs);
    });
    var langSelector = new IQVOC.LanguageSelector(langWidget, "lang_selected");
    if($("#new_concept, #edit_concept").length) { // edit mode
      // disable secondary language selection to avoid excessive state complexity
      $(":checkbox", langSelector.container).prop("disabled", true);
    }
  }

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
  $("fieldset.note_relation input[type=button]").on('click', function(ev) {
    IQVOC.createNote.apply(this, arguments);
    langSelector.notify(); // trigger updateNoteLangs -- XXX: hacky!?
  });
  $("li.inline_note input:checkbox").on('change', function(ev) {
    var action = this.checked ? "addClass" : "removeClass";
    $(this).closest("li")[action]("deleted");
  });

  $('.datepicker').datepicker({
    autoclose: true,
    todayHighlight: true,
    todayBtn: 'linked',
    clearBtn: true,
    format: "yyyy-mm-dd",
    language: locale
  });

  //$("tr.highlightable").click(function(ev) {
    //window.open($(this).attr("data-url"), '_blank');
  //});

  $(".dashboard-glance-link").on('click', function(ev) {
    ev.preventDefault();

    var modal = $("#concept-teaser-modal");
    var target = $(this).attr("href");

    $.get(target, function(data) {
      modal.html(data);
      modal.modal();
    });
  });

  // Search
  $(".checkbox-select-all").on('click', function() {
    $(this).closest('.checkbox-controls').find("input:checkbox").prop("checked", true);
  });
  $(".checkbox-select-none").on('click', function() {
    $(this).closest('.checkbox-controls').find("input:checkbox").prop("checked", false);
  });
  $("select.search_type").on('change', function() {
    var result_type_filter = $(".result_type_filter");
    var selected = $(this).val();
    var targets = ['labels', 'pref_labels', 'alt_labels'];
    if($.inArray(selected, targets) !== -1) {
      result_type_filter.show();
    }
    else {
      result_type_filter.hide();
    }
  });
  $("select.search_type").trigger('change');

  // unobtrusive tabs
  $(".tab-panels").addClass("tab-content"); // the latter is for Bootstrap Tabs

  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
});

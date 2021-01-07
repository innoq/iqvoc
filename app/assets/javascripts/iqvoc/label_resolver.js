(function($) {

  "use strict";

  function retrieveLabel(conceptURL, el, callback) {
    var datasets = $("body").data("datasets");
    var proxy = $("body").data("remote-label-path");
    var matchedDatasets = Object.keys(datasets).filter(function(datasetURL) {
      return conceptURL.indexOf(datasetURL, 0) === 0;
    });

    if (matchedDatasets.length === 0) {
      return false;
    }

    $.get(proxy, { concept_url: conceptURL }, function(data, status, xhr) {
      el.text(data.label);
      el.removeClass("unlabeled");
    });
  }

  function processNode(i, node) {
    var el = $(node);
    var uri = el.attr("href");
    retrieveLabel(uri, el);
  }

  $(function() {
    $("a.unlabeled").each(processNode);

    // initialise new dynamically added links
    $(document.body).on("concept-label", function(ev, container) {
      $("a.unlabeled", container).each(processNode);
    });
  });

}(jQuery));

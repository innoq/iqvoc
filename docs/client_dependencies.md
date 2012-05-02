iQvoc relies on the following third-party components on the client-side:

* jQuery (MIT, http://jquery.com)

* jQuery UI (MIT, http://jqueryui.com)
  * Redmond theme
  * Autocomplete
  * Datepicker (plus customized locale settings in `jquery-ui.datepicker-de.js`)

* jQuery Treeview (extensively customized)
  (MIT, http://bassistance.de/jquery-plugins/jquery-plugin-treeview/)

* JavaScript InfoVis Toolkit (BSD, http://thejit.org)
  * RGraph

* Remy Sharp's `localStorage` polyfill
  (MIT, https://github.com/remy/polyfills/blob/master/Storage.js)


jQuery UI upgrade procedure
---------------------------

* create [custom build](http://jqueryui.com/download), selecting only the
  required components (plus theme)
* unzip custom build to temporary directory (e.g. `/tmp/ui/`)
* execute the following commands:

        git rm vendor/assets/javascripts/jquery-ui-*.custom*.js
        mv /tmp/ui/development-bundle/ui/jquery-ui-*.custom.js vendor/assets/javascripts/
        git rm vendor/assets/stylesheets/jquery-ui-*.custom.css
        mv /tmp/ui/css/redmond/jquery-ui-*.custom.css vendor/assets/stylesheets/
        git rm vendor/assets/images/jquery-ui/*
        mv /tmp/ui/css/redmond/images/* vendor/assets/images/jquery-ui/
        git add vendor/assets/*ts/jquery-ui-*.custom*.{js,css} vendor/assets/images/jquery-ui/

* update `app/assets/javascripts/framework.js` and
  `app/assets/javascripts/framework.js` to reference the new version

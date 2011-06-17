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
* unzip custom build to temporary directory (`/tmp/ui/`)
* `$ git rm public/javascripts/iqvoc/jquery-ui-*.custom*.js`
* `$ mv /tmp/ui/js/jquery-ui-*.custom.min.js public/javascripts/iqvoc/`
* `$ mv /tmp/ui/development-bundle/ui/jquery-ui-*.custom.js public/javascripts/iqvoc/`
* `$ git rm public/stylesheets/iqvoc/jquery-ui-*.custom.css`
* `$ mv /tmp/ui/css/redmond/jquery-ui-*.custom.css public/stylesheets/iqvoc/`
* `$ git rm public/stylesheets/iqvoc/images/ui-*`
* `$ mv /tmp/ui/css/redmond/images/* public/stylesheets/iqvoc/images`
* `$ git add public/*ts/iqvoc/jquery-ui-*.custom*.{js,css} public/stylesheets/iqvoc/images/ui-*`
* update `app/views/layouts/application.html.erb` to point to the new `.js` and
  `.css` files

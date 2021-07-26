module.exports = {
  js: [
    {
      source: "./node_modules/jquery/dist/jquery.js",
      target: "./public/assets/javascripts/jquery.js",
      exports: "jQuery",
      compact: "mangle"
    },
    {
      source: "./app/assets/javascripts/manifest.js",
      target: "./public/assets/javascripts/manifest.js",
      externals:  { jquery: "jQuery" },
    },
    {
      source: "./node_modules/bootstrap/dist/js/bootstrap.bundle.min.js",
      target: "./public/assets/javascripts/bootstrap.bundle.min.js",
      externals:  { jquery: "jQuery" },
      compact: "minify"
    }
  ],
  sass: [{
    source: "./app/assets/stylesheets/manifest.scss",
    target: "./public/assets/stylesheets/manifest.css"
  }],
  static: [{
    source: "./app/assets/images",
    target: "./public/assets/images"
  },
  {
    source: "./app/assets/fonts",
    target: "./public/assets/fonts"
  },
  {
    source: "./node_modules/font-awesome/fonts",
    target: "./public/assets/fonts",
    fingerprint: false
  }
],
  manifest: {
    target: "./public/assets/manifest.json",
    key: "short",
    webRoot: "./public"
  },
  watchDirs: ["./app/assets"]
};

# iQvoc

[![Build Status](https://secure.travis-ci.org/innoq/iqvoc.png)](http://travis-ci.org/innoq/iqvoc)

iQvoc is a vocabulary management tool that combines easy-to-use human interfaces with Semantic Web interoperability.

iQvoc supports vocabularies that are common to many knowledge organization systems, such as:

* Thesauri
* Taxonomies
* Classification schemes
* Subject heading systems

iQvoc provides comprehensive functionality for all aspects of managing such vocabularies:

* import of existing vocabularies from a SKOS representation
* multilingual display and navigation in any Web browser
* editorial features for registered users
* publishing the vocabulary in the Semantic Web

iQvoc is built with state-of-the-art technology and can be easily customized according to user's needs.

## Setup

### Heroku

You can easily setup your iQvoc instance in under 5 minutes, we wanted to make this process really easy.

To run iQvoc on heroku do the following:

```
bundle install
heroku create
bundle exec rake heroku:config
git push heroku master
heroku rake db:migrate
heroku rake db:seed
heroku restart
```

`heroku open` opens your app in the browser.

Remember to visit the Users section and change the default passwords!

**Remarks:** 
For now iQvoc only supports the standard Bamboo stack. Cedar is not supported as we have `sqlite3` as a dependency
in the Gemfile and Cedar does not support a custom `BUNDLE_WITHOUT` config like Bamboo at the moment.

### Custom

1. Configure your database via `config/database.template.yml`. Don't forget to rename it to `database.yml`
2. Run `bundle install`
3. Run `bundle exec rake db:create` to create the database
4. Create the necessary tables by running `rake db:migrate`
5. Load some base data by running `rake db:seed`
6. Run `bundle exec rake setup:generate_secret_token`
7. Boot up the app using `bundle exec rails s` (or `passenger start` if you use passenger)
8. Log in with "admin@iqvoc" / "admin" or "demo@iqvoc" / "cooluri" (cf. step #5)
9. Visit the Users section and change the default passwords

## Compatibility

iQvoc is fully compatible with Ruby 1.9.2, 1.8.7 and JRuby 1.6.

## Customization

There are many hooks providing support for your own classes and configuration. The core app
also works as a Rails Engine. The config residing in `lib/iqvoc.rb` provides a basic
overview of the possibilities.

## Documentation

Documentation resources can be found in the [wiki](https://github.com/innoq/iqvoc/wiki/_pages).

## Contributing

If you want to help out there are several options:

* Found a bug? Just create an issue on the [GitHub Issue tracker](https://github.com/innoq/iqvoc/issues) and/or submit a patch by initiating a pull request
* You're welcome to fix bugs listed under [Issues](https://github.com/innoq/iqvoc/issues)
* Proposal, discussion and implementation of new features on our mailing list iqvoc@lists.innoq.com or on the issue tracker

If you make changes to existing code please make sure that the test suite stays green. Please include tests to your additional contributions.

Tests can be run via `bundle exec rake test`. We're using capybara-webkit for integration tests with JavaScript support.

## Maintainer & Contributors

iQvoc was originally created and is being maintained by [innoQ Deutschland GmbH](http://innoq.com).

* Robert Glaser ([mrreynolds](http://github.com/mrreynolds))
* Till Schulte-Coerne ([tillsc](http://github.com/tillsc))
* Frederik Dohr ([FND](http://github.com/FND))

## License

Copyright 2011 innoQ Deutschland GmbH
Licensed under the Apache License, Version 2.0

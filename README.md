# iQvoc

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

## Getting Started

1. Configure your database via `config/database.template.yml`
2. `bundle install`
3. Run `rake db:create` to create the database
4. Create the necessary tables by running `rake db:migrate`
5. Load some base data by running `rake db:seed`
6. Boot up the app using `rails s` (or `passenger start` if you use passenger)
7. Login via `admin@iqvoc` / `cooluri` (requires step 5. to be run)

## Compatibility

iQvoc is fully compatible with Ruby 1.9.2, 1.8.7 and JRuby 1.6.

## Customization

There are many hooks providing support for your own classes and configuration. The core app
also works as a Rails Engine. The config residing in `lib/iqvoc.rb` provides a basic
overview of the possibilities.

## Contributing

If you want to help out there are several options:

* Found a bug? Just create an issue on the [GitHub Issue tracker](https://github.com/innoq/iqvoc/issues) and/or submit a patch by initiating a pull request
* You're welcome to fix bugs listed under [Issues](https://github.com/innoq/iqvoc/issues)
* Proposal, discussion and implementation of new features on our mailing list [iqvoc@lists.innoq.com]((iqvoc@lists.innoq.com)) or on the issue tracker

If you make changes to existing code please make sure that the test suite stays green. Please include tests to your additional contributions.

Tests can be run via `rake test`. We're using capybara-webkit for integration tests with JavaScript support.

## Maintainer & Contributors

iQvoc was originally created and is being maintained by [innoQ Deutschland GmbH](http://innoq.com).

* Robert Glaser ([mrreynolds](http://github.com/mrreynolds))
* Till Schulte-Coerne ([tillsc](http://github.com/tillsc))
* Frederik Dohr ([FND](http://github.com/FND))

## License

Copyright 2011 innoQ Deutschland GmbH
Licensed under the Apache License, Version 2.0

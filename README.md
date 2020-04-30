# iQvoc

[![Gem Version](https://badge.fury.io/rb/iqvoc.png)](http://badge.fury.io/rb/iqvoc)
![CI](https://github.com/innoq/iqvoc/workflows/CI/badge.svg?branch=master)
[![Code Climate](https://codeclimate.com/github/innoq/iqvoc.png)](https://codeclimate.com/github/innoq/iqvoc)

iQvoc is a vocabulary management tool that combines easy-to-use human interfaces
with Semantic Web interoperability.

iQvoc supports vocabularies that are common to many knowledge organization
systems, such as:

* Thesauri
* Taxonomies
* Classification schemes
* Subject heading systems

iQvoc provides comprehensive functionality for all aspects of managing such
vocabularies:

* import of existing vocabularies from a SKOS representation
* multilingual display and navigation in any Web browser
* editorial features for registered users
* publishing the vocabulary in the Semantic Web

iQvoc is built with state-of-the-art technology and can be easily customized according to user's needs.

## Demo

You can try out iQvoc right now! In our [sandbox](http://try.iqvoc.net/) you can play around with the public views.
If you like to test the collaborative functions simply [request](mailto:iqvoc@innoq.com) your personal demo account.

## Setup

### Heroku

You can easily setup your iQvoc instance in under 5 minutes, we wanted to make
this process really easy. In order to deploy to heroku you need to have an
account and [heroku toolbelt](https://toolbelt.heroku.com) installed.

```
$ bundle install
$ heroku create
$ heroku config:add HEROKU=true RAILS_ENV=heroku RACK_ENV=heroku SECRET_KEY_BASE=$(bundle exec rake secret)
$ git push heroku master
$ heroku run rake db:migrate
$ heroku run rake db:seed
$ heroku restart
```

`heroku open` opens your app in the browser.

Remember to visit the Users section and change the default passwords!

### Docker

If you want to try iQvoc using Docker just clone this repository and run:

```
$ docker-compose up
```

This Setup uses Postgres as a database. Please make sure that your Docker daemon is running and that you have docker-compose installed. User credentials can be found in https://github.com/innoq/iqvoc/blob/master/db/seeds.rb.

### Custom

We recommend running [iQvoc as a Rails engine](https://github.com/innoq/iqvoc/wiki/iQvoc-as-a-Rails-Engine).
Running the cloned source code is possible but any modifications would require a
fork.

1. Configure your database via `config/database.template.yml`.
   Don't forget to rename it to `database.yml`
2. Run `bundle install`
3. Run `bundle exec rake db:create` to create the database
4. Create the necessary tables by running `rake db:migrate`
5. Load some base data by running `rake db:seed`
6. Make sure you have got `config/secrets.yml` in place
7. Boot up the app using `bundle exec rails s` (or `passenger start`
   if you use passenger)
8. Log in with "admin@iqvoc" / "admin" or "demo@iqvoc" / "cooluri" (cf. step #5)
9. Visit the Users section and change the default passwords

## Background Jobs

Note that some features like "Import" and "Export" exposed in the Web UI store
their workload as jobs. You can either issue a job worker that runs continuously
and watches for new jobs via

```
$ rake jobs:work
```

or process jobs in a one-off way (in development or via cron):

```
$ rake jobs:workoff
```

## Compatibility

iQvoc is fully compatible with Ruby 2.2, 2.3 and 2.4.

## Customization

There are many hooks providing support for your own classes and configuration.
The core app also works as a Rails Engine. The config residing in `lib/iqvoc.rb`
provides a basic overview of the possibilities.

## Documentation

Documentation resources can be found in the [wiki](https://github.com/innoq/iqvoc/wiki).

iQvoc provides an (inline) API documentation which can be found on `APP_URI/apidoc`. Check out our sandbox to see it in action: http://try.iqvoc.net/apidoc/

## Related projects

We provide several extensions to add additional features to iQvoc:

* [iqvoc_skosxl](https://github.com/innoq/iqvoc_skosxl): SKOS-XL extension for iQvoc
* [iqvoc_compound_forms](https://github.com/innoq/iqvoc_compound_forms): Compound labels for iQvoc
* [iqvoc_inflectionals](https://github.com/innoq/iqvoc_inflectionals): Inflectionals for iQvoc
* [iqvoc_similar_terms](https://github.com/innoq/iqvoc_similar_terms):  iQvoc engine for similar terms

## Versioning

Releases will follow a semantic versioning format:

    <major>.<minor>.<patch>

For more information on SemVer, visit http://semver.org/.

## Contributing

If you want to help out there are several options:

- Found a bug? Just create an issue on the
  [GitHub Issue tracker](https://github.com/innoq/iqvoc/issues) and/or submit a
  patch by initiating a pull request
- You're welcome to fix bugs listed under
  [Issues](https://github.com/innoq/iqvoc/issues)
- Proposal, discussion and implementation of new features on our mailing list
  [iqvoc@lists.innoq.com] or on the issue tracker

If you make changes to existing code please make sure that the test suite stays
green. Please include tests to your additional contributions.

Tests can be run via `bundle exec rake test`. We're using Poltergeist for
integration tests with JavaScript support.

## Maintainer & Contributors

iQvoc was originally created and is being maintained by [innoQ Deutschland GmbH](http://innoq.com).

* Robert Glaser ([mrreynolds](http://github.com/mrreynolds))
* Till Schulte-Coerne ([tillsc](http://github.com/tillsc))
* Frederik Dohr ([FND](http://github.com/FND))
* Marc Jansing ([mjansing](http://github.com/mjansing))

## License

Copyright 2015 [innoQ Deutschland GmbH](https://www.innoq.com).

Licensed under the Apache License, Version 2.0.

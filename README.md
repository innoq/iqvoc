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

## Customization

There are many hooks providing support for your own classes and configuration. The core app
also works as a Rails Engine. The config residing in `lib/iqvoc.rb` provides a basic
overview of the possibilities.

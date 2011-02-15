# iQvoc

iQvoc is a vocabulary management tool that combines easy-to-use human interfaces with Semantic Web interoperability.

iQvoc supports vocabularies that are common to many knowledge organisation systems, such as:

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
5. Boot up the app using `rails s` (or `passenger start` if you use passenger)

## Deeper customization

There are many hooks providing support for your own classes and configuration. The core app
is extendable via Rails Engines. The core config residing in `lib/iqvoc.rb` provides a basic
overview of the possibilities. As an example for close vendor tailoring the core to your needs,
see `EXAMPLE`.

## Glitches/Bugs/ToDo

There are still several glitches and bugs we directly know of. They are marked with
`# TODO` and `# FIXME` in the sources.

### "Nested Validations"
Validations have to be specified directly in the class they belong to. E.g. if
you want to check that there is only one pref_label per concept this should be
done in the Labeling class and not in the Concept or Label.

The problem in which form validation errors from nested invalid objects are
shown up when saving the "main" object is still open.

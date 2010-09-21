# iQvoc

iQvoc is a vocubulary management system built on the semantic web.

## Getting Started

1. Run rake app:bootstrap to setup basic users
2. Start the app with rails s

## Great TODO tasks ("beyont FIXMEs"):

### "Nested Validations"
Validations have to be specified directly in the class they belong to. E.g. if
you want to check that there is only one pref_label per concept this should be
done in the Labeling class and not in the Concept or Label.

The problem in which form validation errors from nested invalid objects are
shown up when saving the "main" object is still open.

### "Common*" modules
The mdules shoulb be refactored from the content based ("CommonScopes") to
a behaviour based ("Versionable").

But the main part will probably be the review of the included functionalitiy in
the context of the generalization. E.g. there is a scope named "published" in
the not versionable Label::Base class. This scope is actually overwritten by the
included module. Does this work properly? Should the scopes be extracted from
the modules? ...

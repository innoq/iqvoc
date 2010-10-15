ActiveRecord::Base.store_full_sti_class = true
ActiveRecord::Base.send :include, SearchExtension

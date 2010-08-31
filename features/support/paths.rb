module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
      
    when /the about page/
      about_path(:lang => 'de')
    
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    
    when /the hierarchical concepts page/
      hierarchical_concepts_path(:lang => 'de')
      
    when /the alphabetical concepts page for the letter "(.)"/
      alphabetical_concepts_path(:lang => 'de', :letter => $1)
      
    when /the concept page for "(.+)"/
      language_concept_path(:de, Concept.find_by_origin($1))
      
    when /the versioned concept page for "(.+)"/
      versioned_concept_path(:de, Concept.find_by_origin($1))
    
    when /the edit versioned concept page for "(.+)"/
      edit_versioned_concept_path(:de, Concept.find_by_origin($1))
      
    when /the label page for "(.+)"/
      language_label_path(:de, Label.find_by_origin($1))
      
    when /the (.+)-formatted label page for "(.+)"/
      label_path(Label.find_by_origin($2), :format => $1)
      
    when /the (.+)-formatted concept page for "(.+)"/
      concept_path(Concept.find_by_origin($2), :format => $1)
      
    when /the (.+)-formatted label page for "(.+)"/
      label_path(Label.find_by_origin($2), :format => $1)
      
    when /the search page/
      search_path(:lang => 'de')
      
    when /the dashboard page/
      dashboard_path(:lang => 'de')

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

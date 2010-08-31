require  'builder'

class SnsServicesController < ApplicationController
  
  skip_before_filter :require_user
  
  def get_synonyms

    token = params[:term]
    puts "got request for:" + token
    
    if token.nil? 
      create_error_message_for("", "not a valid term. Parameter needs to be: term[]=...") 
      token = []
    end
      
    # 1
    # if tokens.size == 1
      label = get_label_from_file_for(token)
      # label = get_label_for_single_token(tokens.first)  
      # identify_concept_from(label)
    # end
    
    # 2
    # if tokens.size > 1 and @labels.nil?
    #   identify_label_from_multi_tokens(tokens)
    # end
    
    # 3
    if @labels.nil?
      create_error_message_for( token.inspect, "no result identified for:") 
    end

    respond_to do |format|
      format.xml  { render :xml => @labels }
    end
  end
  
  private 
  
  def get_label_from_file_for(term)
    
    file = File.new("#{RAILS_ROOT}/lib/demitufisnohnebksyn20100217.txt")
    csv_data = Iconv.iconv('utf-8', 'ISO_8859-1', file.read).to_s
    
    # @labels = {}
    
    @labels = ''

    xml = Builder::XmlMarkup.new(:indent=>2, :target => @labels)
    xml.instruct!
    xml.iqvoc {
      xml.search {
        xml.term term
      }
      xml.results {
        csv_data.each_line("\r\n") do |row|
          
           columns = row.split(";")
           search_column = columns[1].to_s.chomp

           if search_column.eql? term and columns.size == 2
             xml.term column[1]
           elsif search_column.eql? term and columns.size > 2
             columns[2..columns.length].each do |col|
               xml.term col.chomp
             end
           end
          
        end
      }
    }
    
  end
  
  def get_label_for_single_token(term)
    labels = get_labels_for(term)
  
    # 1.2.1
    if labels.size == 1
      label = labels.first
    # 1.2.2
    # elsif inflectionals_contains_duplicate_labels_for?(params[:term])
    #   create_error_message("duplicate record found for:", params[:term])
    # 1.2.3
    elsif labels.empty?
      create_error_message_for("no record found for:", term)
    end
  end
  
  def identify_concept_from(label)
    # 1.3.1
    if label.concepts.size == 1
       get_literal_form_from_labelings(label.concepts.first.labelings)
    # 1.3.2
    elsif label.concepts.size > 1
      num_alt_labels = 0
      num_pref_labels = 0
      label.concepts.each { |concept| 
        num_alt_labels += concept.alt_labels.size
        num_pref_labels += concept.pref_labels.size
      }
      # 1.3.2.1
      if num_alt_labels > 0 and num_pref_labels == 0
        # concepte aneinanderhängen ?
      # 1.3.2.2
      elsif num_pref_labels > 0
        create_error_message_for("multiple pref labels found", term) 
      # 1.3.2.3
      elsif num_pref_labels > 0 and num_alt_labels > 0
        # goto 2
      end
    # 1.3.3
    elsif label.concepts.empty?
      if label_is_part_of_homograph?(label)
        # => goto 2 
      elsif label_has_lexical_extension(label)
        label = get_lexical_extension(label) 
        identify_concept_from(label)
      elsif check_compound_forms(label.labelings)
        # => goto 2
      end        
    end
  end
  
  def identify_label_from_multi_tokens(terms)
    terms.each { |term|
      puts "checking for term " + term
      label = get_label_for_single_token(term)
      label.reverse_compound_form_contents.each { |compound_forms|
        
      }
    }
  end
  
  def get_labels_for(term)
    Label.find(:all, :conditions => { :value => term } )
  end
  
  def label_is_part_of_homograph?(label) 
    (label.homographs.empty? and label.qualifiers.empty?) ? false : true
  end
  
  def label_has_lexical_extension(label)
    # => sind noch nicht vorhanden
    # label.lexical_extensions.empty? ? false : true
  end
  
  def get_lexical_extension(label)
    # label.lexical_extensions
  end
  
  def inflectionals_contains_duplicate_labels_for?(term)
    base_form = get_base_form_for(term)
    inflectionals = Inflectional.find(:all, :conditions => { :value => base_form})
    inflectionals.collect! { |inflectional| inflectional = inflectional.label_id }
    inflectionals.uniq! == nil ? false : true
  end
  
  def get_base_form_for(label_value)
    Label.find_by_value(label_value).base_form
  end
  
  def get_labelings_by_label(label)
    Labeling.find(:all, :conditions => { :target_id => label.id } )    
  end
  
  def get_labelings_by_concept_id(concept_id)
    Labeling.find(:all, :conditions => { :owner_id => concept_id} )
  end
  
  def get_literal_form_from_labelings(labelings)
    @labels = {}
    labelings.each{ |labeling|
      label = Label.find_by_id(labeling.target_id)
      @labels[label.id] = label.literal_form
    }
    
    @labels
  end
  
  def create_error_message_for(label, message)
    @labels = {}
    @labels["message"] = "#{message} #{label}"
  end
  
  def check_compound_forms(labelings)
    compound_labels = []
        
    labelings.each do |labeling|
      label = Label.find_by_id(labeling.target_id)
      puts label
      label.reverse_compound_form_contents.each{ |compound_form|
          forms = UMT::CompoundFormContent.find(:all, :conditions => {:compound_form_id => compound_form.compound_form_id} )
          forms.each { |form|
              puts Label.find_by_id(form.label_id).inspect
              
          }
      }
    end
  end
  
end
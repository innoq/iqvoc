class DashboardController < ApplicationController
  
  before_filter :check_authorization
  
  def index
    @concepts = Concept.for_dashboard.all(:include => [:locking_user, :pref_labels])
    @labels   = Label.for_dashboard.all(:include => [:locking_user])
    
    @items    = @concepts + @labels
    
    @items.sort! { |x,y| y.updated_at <=> x.updated_at } rescue nil
    
    case params[:by]
    when "class"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.class.to_s.downcase <=> y.class.to_s.downcase }
      when "desc": @items.sort! { |x,y| y.class.to_s.downcase <=> x.class.to_s.downcase }
      end
    when "value"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.to_s.downcase <=> y.to_s.downcase }
      when "desc": @items.sort! { |x,y| y.to_s.downcase <=> x.to_s.downcase }
      end
    when "locking_user"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.locking_user.name.downcase <=> y.locking_user.name.downcase } rescue nil
      when "desc": @items.sort! { |x,y| y.locking_user.name.downcase <=> x.locking_user.name.downcase } rescue nil
      end
    when "follow_up"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.follow_up <=> y.follow_up } rescue nil
      when "desc": @items.sort! { |x,y| y.follow_up <=> x.follow_up } rescue nil
      end
    when "updated_at"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.updated_at <=> y.updated_at } rescue nil
      when "desc": @items.sort! { |x,y| y.updated_at <=> x.updated_at } rescue nil
      end
    when "state"
      case params[:order]
      when "asc" : @items.sort! { |x,y| x.state <=> y.state } rescue nil
      when "desc": @items.sort! { |x,y| y.state <=> x.state } rescue nil
      end
    end
  end
  
  private
  def check_authorization
    authorize! :use, :dashboard
  end
  
end
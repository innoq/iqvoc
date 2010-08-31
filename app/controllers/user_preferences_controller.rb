class UserPreferencesController < ApplicationController

  # GET /user_preferences
  # GET /user_preferences.xml
  def index
    @user_preferences = UserPreference.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_preferences }
    end
  end

  # GET /user_preferences/1
  # GET /user_preferences/1.xml
  def show
    @user_preference = UserPreference.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_preference }
    end
  end

  # GET /user_preferences/new
  # GET /user_preferences/new.xml
  def new
    @user_preference = UserPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_preference }
    end
  end

  # GET /user_preferences/1/edit
  def edit
    @user_preference = UserPreference.find(params[:id])
  end

  # POST /user_preferences
  # POST /user_preferences.xml
  def create
    @user_preference = UserPreference.new(params[:user_preference])

    respond_to do |format|
      if @user_preference.save
        flash[:notice] = 'UserPreference was successfully created.'
        format.html { redirect_to(@user_preference) }
        format.xml  { render :xml => @user_preference, :status => :created, :location => @user_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_preferences/1
  # PUT /user_preferences/1.xml
  def update
    @user_preference = UserPreference.find(params[:id])

    respond_to do |format|
      if @user_preference.update_attributes(params[:user_preference])
        flash[:notice] = 'UserPreference was successfully updated.'
        format.html { redirect_to(@user_preference) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_preference.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_preferences/1
  # DELETE /user_preferences/1.xml
  def destroy
    @user_preference = UserPreference.find(params[:id])
    @user_preference.destroy

    respond_to do |format|
      format.html { redirect_to(user_preferences_url) }
      format.xml  { head :ok }
    end
  end
end

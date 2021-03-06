class Sites::Admin::MenusController < ApplicationController
  before_filter :require_user
  before_filter :check_authorization

  respond_to :html, :xml, :js
  def index
    @menus = current_site.menus
    @menu = params[:menu] ? @menus.select{|menu| menu.id == params[:menu].to_i}[0] : @menus.first
  end

  def show
    redirect_to site_admin_menus_path(:menu => params[:id])
  end

  def new
    @menu = Menu.new
  end
  
  def create
    @menu = current_site.menus.new(params[:menu])
    if @menu.save
      flash[:success] = t("successfully_created")
      record_activity("created_menu", @menu)
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def edit
    @menu = current_site.menus.find(params[:id])
  end

  def update
    @menu = current_site.menus.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:success] = t("successfully_updated")
      record_activity("updated_menu", @menu)
      redirect_to site_admin_menus_path(:menu => @menu.id)
    else
      respond_with(:site_admin, @menu)
    end
  end

  def destroy
    @menu = current_site.menus.find(params[:id])
    @menu.destroy
    flash[:success] = t("successfully_deleted")
    record_activity("destroyed_menu", @menu)
    redirect_to site_admin_menus_path
  end

end

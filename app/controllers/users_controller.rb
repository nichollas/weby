# coding: utf-8
class UsersController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :except => [:new, :create]
  before_filter :check_authorization, :except => [:new, :create, :show]
	before_filter :get_theme
  respond_to :html, :xml
  helper_method :sort_column

  def change_theme
    if params[:id] && current_user
      @user = current_user
      @user.update_attribute(:theme, params[:id])
      flash[:notice] = t("look_changed")
    end
    redirect_back_or_default root_path
  end

  def manage_roles
    # Se a ação for selecionada para um site:
    if @site
      # Seleciona os todos os usuários que não são administradores
      @users = User.no_admin
      # Usuários que possuem papel no site e não são administradores
      @site_users = User.by_site(@site) - User.admin
      # Usuários que NÃO possuem papel no site e não são administradores
      @users_unroled = User.by_no_site(@site) - User.admin

      # Busca os papéis do site e global
      @roles = @site.roles.order("id")
      # Quando a edição dos papeis é solicitada
      @user = User.find(params[:user_id]) if params[:user_id]
    else
      #@sites = Site.all.except(:order).page(params[:page]).per(params[:per_page])
      @sites = Site.name_or_description_like(params[:search]).
        except(:order).
        order(sort_column + " " + sort_direction).
        page(params[:page]).
        per(params[:per_page])
      render :select_site
    end
  end

  def change_roles
    params[:role_ids] ||= []
    user_ids = []
    user_ids.push(params[:user][:id]).flatten!

    user_ids.each do |id|
      user = User.find(id)
      # Limpa os papeis do usuário no site
      user.role_ids.each do |r_id|
        if @site.roles.map{|r| r.id }.index(r_id)
          user.role_ids -= [r_id]
        end
      end
      # NOTE Talvez seja melhor usar (user.role_ids += params[:role_ids]).uniq
      # assim removemos o each logo a cima
      user.role_ids += params[:role_ids]
    end
    redirect_to :action => 'manage_roles'
  end

  def index
    @users = User.login_or_name_like(params[:search]).
      order(sort_column + " " + sort_direction).page(params[:page]).
      per(params[:per_page]) 

    if @site and not current_user.is_admin?
      @users = @users.by_site(@site.id)
    end

    @roles = Role.select('id, name, theme').
      group("id, name, theme").order("id")

    unless @users
      flash.now[:warning] = (t"none_param", :param => t("user.one"))
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Conta registrada!"
      redirect_to @site ? site_users_path : users_path
    else
      render :action => :new
    end
  end

  def show
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def edit
    @user = User.find(params[:id])
    respond_with(@user)
  end

  def update
    unless current_user.is_admin
      params[:id] = current_user.id
    end
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    flash[:notice] = t"updated", :param => t("account")
    respond_with(@user)
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to @site ? site_users_path : users_path, :notice => t('destroyed_param', :param => @user.first_name)
  end

  def toggle_field
    @user = User.find(params[:id])
    if params[:field] 
      if @user.update_attributes(params[:field] => (@user[params[:field]] == 0 or not @user[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_to @site ? site_users_path : users_path
  end
  
  def set_admin
    @user = User.find(params[:id])
    if params[:field] 
      if @user.update_attributes(params[:field] => (@user[params[:field]] == 0 or not @user[params[:field]] ? true : false))
        flash[:notice] = t"successfully_updated"
      else
        flash[:notice] = t"error_updating_object"
      end
    end
    redirect_to @site ? site_users_path : users_path
  end

  private
  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : 'id'
  end
	# Cria uma variável themes com base nos temas disponíveis
	def get_theme
    files = []
    for file in Dir[File.join(Rails.root + "app/views/layouts/[a-zA-Z]*")]
      files << file.split("/")[-1].split(".")[0]
    end
    @themes = files
	end
end

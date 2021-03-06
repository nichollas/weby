class NotificationsController < ApplicationController
  before_filter :require_user
  respond_to :html, :js
  layout 'weby_pages'

  def index
    params[:page] ||= 1
    @per_notif = 25
    @notifications = Notification.title_or_body_like(params[:search]).
                     order("created_at DESC").
                     page(params[:page]).
                     per(@per_notif)

    @nexturl = notifications_path(page: params[:page].to_i+1, search: params[:search])

    if request.xhr?
      render partial: 'list', layout: false
    end
  end

  def show
    @notification = Notification.find(params[:id])
    set_as_read @notification
  end

  def mark_as_read
    set_as_read
    redirect_to notifications_path
  end

  private
  def set_as_read notification=nil
    user = User.find(current_user.id)
    user.remove_unread_notification notification
  end
end

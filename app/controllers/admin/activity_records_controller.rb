class Admin::ActivityRecordsController < ApplicationController
  before_filter :require_user
  before_filter :is_admin
  respond_to :html, :js

  def index
    @activity_records = ActivityRecord.user_or_action_like(params[:search], params[:site_id]).
                order("activity_records.created_at DESC").
                page(params[:page]).
                per(params[:per_page] || per_page_default)
  end

  def show
    @activity_record = ActivityRecord.find(params[:id])
  end

  def destroy
    @activity_record = ActivityRecord.find(params[:id])
    @activity_record.destroy
    flash[:success] = t("destroyed_record")

    redirect_to :back
  end
end

module Feedback
  class FeedbackMailer < ActionMailer::Base
    def send_feedback (feedback, destination, site)
      @feedback = feedback
      @site_title = site.title
      mail(:from => feedback.email, :reply_to => feedback.email, :to => destination, :subject => feedback.subject)
    end
  end
end

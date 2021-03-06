module Trashable
  extend ActiveSupport::Concern
  
  included do
    default_scope where(deleted_at: nil)

    def self.trashed
      unscoped.where("deleted_at is not null")
    end

    define_model_callbacks :trash, :untrash
  end
        
  def trash
    if deleted_at
      destroy
    else
      run_callbacks :trash do
        update_attribute(:deleted_at, Time.now)
      end
    end
  end

  def untrash
    run_callbacks :untrash do
      update_attribute(:deleted_at, nil)
    end
  end
end

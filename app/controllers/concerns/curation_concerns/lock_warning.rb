module CurationConcerns::LockWarning
  extend ActiveSupport::Concern

  included do
    before_action :lock_warning

    def lock_warning
      flash.now[:alert] = "This object is currently queued for processing." if presenter.lock?
    end
  end
end

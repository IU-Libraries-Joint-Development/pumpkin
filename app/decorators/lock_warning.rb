class LockWarningDecorator < Decorator
  def show
      flash.now[:notice] = "This object is currently queued for processing." if curation_concern.lock?
      super
  end

end


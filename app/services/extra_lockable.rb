module ExtraLockable
  extend ActiveSupport::Concern
  include CurationConcerns::Lockable

  # Provides a way to pass options to the underlying Redlock client.
  def lock(key, options = {})
    ttl = options.delete(:ttl) || CurationConcerns.config.lock_time_to_live
    if block_given?
      lock_manager.client.lock(key, ttl, options, &Proc.new)
    else
      lock_manager.client.lock(key, ttl, options)
    end
  end

  def lock?(key)
    acquire_lock_for(key) { nil }
    return false
  rescue CurationConcerns::LockManager::UnableToAcquireLockError
    return true
  end

  def unlock(lock_info)
    lock_manager.client.unlock lock_info
  end
end

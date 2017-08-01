module ExtraLockable
  extend ActiveSupport::Concern
  include CurationConcerns::Lockable

  def lock?(key)
    lock_manager.lock(key) { nil }
    return false
  rescue CurationConcerns::LockManager::UnableToAcquireLockError
    return true
  end
end

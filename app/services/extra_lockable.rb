module ExtraLockable
  extend ActiveSupport::Concern
  include CurationConcerns::Lockable

  included do
    # TODO: Handle when id is nil or not defined.
    def lock_id
      raise ArgumentError.new("id cannot be blank") if try(:id).blank?
      "lock_#{id}"
    end

    # Provides a way to pass options to the underlying Redlock client.
    def lock(key = lock_id, options = {})
      ttl = options.delete(:ttl) || CurationConcerns.config.lock_time_to_live
      if block_given?
        lock_manager.client.lock(key, ttl, options, &Proc.new)
      else
        lock_manager.client.lock(key, ttl, options)
      end
    end

    def lock?(key = lock_id)
      acquire_lock_for(key) { nil }
      Rails.logger.info "ExtraLockable: No lock found for key: #{key}"
      return false
    rescue CurationConcerns::LockManager::UnableToAcquireLockError
      Rails.logger.info "ExtraLockable: Found a lock for key: #{key}"
      return true
    end

    def unlock(lock_info)
      lock_manager.client.unlock lock_info
    end
  end
end

module LockableJob
  extend ActiveSupport::Concern

  def self.prepended(mod)
    # attr_accessor :lock_info
    mod.class_eval do
      before_enqueue do |job|
        job.arguments << { lock_info: job.arguments.first.lock } # First arg should be something that includes ExtraLockable
      end

      before_perform do |job|
        job.arguments << { lock_info: job.arguments.first.lock } unless lock_info?(job.arguments)
      end

      after_perform do |job|
        job.arguments.first.try :unlock, job.arguments.last[:lock_info]
      end
    end
  end

  def perform(*args)
    args.pop if lock_info?(args) # Run the job with only the original arguments
    super(*args)
  end

  private

    def lock_info?(args)
      args.last.is_a?(Hash) && args.last.key?(:lock_info)
    end
end

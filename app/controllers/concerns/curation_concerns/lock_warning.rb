module CurationConcerns
  module LockWarning
    extend ActiveSupport::Concern
    def decorator
      ::LockWarning
    end
  end
end

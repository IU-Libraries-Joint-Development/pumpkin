module CollectionIndexing
  extend ActiveSupport::Concern
  included do
    self.indexer = ::WorkIndexer
  end
end

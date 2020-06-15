module CollectionAssociationDestruction
  # returns Array of ActiveFedora::Aggregation::Proxy
  def collection_membership
    member_relation = ActiveFedora::Base.find("#{id}/member_of_collections")
    member_relation.contained.map { |c| ActiveFedora::Base.find c.id.split('/')[-3, 3].join('/') }
  end

  def destroy_collection_membership
    collection_membership.map(&:destroy)
  end
end

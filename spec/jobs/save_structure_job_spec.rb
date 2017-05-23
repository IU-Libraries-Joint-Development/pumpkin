require "rails_helper"

RSpec.describe SaveStructureJob do
  it "matches with enqueued job" do
    # The :test adapter is required for these matchers
    ActiveJob::Base.queue_adapter = :test
    expect {
      described_class.perform_later
    }.to have_enqueued_job(described_class)

    expect {
      described_class.perform_later("work", "structure")
    }.to have_enqueued_job.with("work", "structure")

    # Set the adapter back to :inline for subsequent tests
    ActiveJob::Base.queue_adapter = :inline
  end
end

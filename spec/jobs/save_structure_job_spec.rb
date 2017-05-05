require "rails_helper"

RSpec.describe SaveStructureJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      described_class.perform_later
    }.to have_enqueued_job(described_class)

    expect {
      described_class.perform_later("work", "structure")
    }.to have_enqueued_job.with("work", "structure")
  end
end

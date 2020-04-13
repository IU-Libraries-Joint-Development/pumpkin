require 'rails_helper'

RSpec.describe "Purl Routing" do
  it "routes to the default action" do
    expect(get(default_purl_path(id: "1"))) \
      .to route_to controller: "purl", action: "default", id: "1"
    expect(get("/purl/unit/collection/1")) \
      .to route_to controller: "purl", action: "default", id: "unit/collection/1"
  end
end

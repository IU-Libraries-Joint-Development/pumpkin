require 'rails_helper'

RSpec.describe LanguageService do
  describe ".label" do
    context "when the label exists in the iso639 file" do
      it "returns it" do
        expect(described_class.label("aar")).to eq "Afar"
      end
    end
    context "when the label doesn't exist" do
      it "returns the label passed to it" do
        expect(described_class.label("zzz")).to eq "zzz"
      end
    end
  end
end

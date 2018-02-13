require 'rails_helper'

RSpec.describe DownloadsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:fileset) { FactoryGirl.build(:file_set) }
  let(:doc) { File.open(Rails.root.join("spec", "fixtures", "files", "test.hocr")) }

  before do
    Hydra::Works::AddFileToFileSet.call(fileset, doc, :extracted_text)
  end

  describe "show" do
    context "requested extracted text" do
      it "renders the extracted text file" do
        get :show, file: 'extracted_text'
        expect(response.body).to eq doc
      end
    end
  end
end

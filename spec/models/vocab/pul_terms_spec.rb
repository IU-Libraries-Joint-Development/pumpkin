require 'rails_helper'

RSpec.describe PULTerms do
  describe "terms" do
    {
      exhibit_id: 'Exhibit ID',
      metadata_id: 'Metadata ID',
      source_metadata: 'Source Metadata',
      ocr_language: 'OCR Language',
      pdf_type: 'PDF Type',
      call_number: 'Call Number',
      published: 'Published',
      visibility: 'Visibility',
      full_text_searchable: 'Search within'
    }.each do |term, label|
      describe term.to_s do
        it "has the right label" do
          expect(described_class.send(term).label).to eq label
        end
      end
    end
  end
end

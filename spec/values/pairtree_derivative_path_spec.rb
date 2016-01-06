require 'rails_helper'

describe PairtreeDerivativePath do
  before do
    allow(CurationConcerns.config).to receive(:derivatives_path).and_return('tmp')
  end

  describe '.derivative_path_for_reference' do
    subject { described_class.derivative_path_for_reference(object, destination_name) }

    let(:object) { double(id: '08612n57q') }
    let(:destination_name) { 'thumbnail' }

    it { is_expected.to eq 'tmp/08/61/2n/57/q-thumbnail.jpeg' }
    context "when given an intermediate file" do
      let(:destination_name) { 'intermediate_file' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-intermediate_file.jp2' }
    end
    context "when given an unrecognized file" do
      let(:destination_name) { 'unrecognized' }

      it { is_expected.to eq 'tmp/08/61/2n/57/q-unrecognized.unrecognized' }
    end
    context "when given a PDF" do
      let(:destination_name) { 'pdf' }
      it "returns a unique PDF path based on the resource identifier" do
        identifier = instance_double(ResourceIdentifier)
        allow(ResourceIdentifier).to receive(:new).with(object.id).and_return(identifier)
        allow(identifier).to receive(:to_s).and_return("banana")

        expect(subject).to eql "tmp/08/61/2n/57/q-banana-pdf.pdf"
      end
    end
  end
end

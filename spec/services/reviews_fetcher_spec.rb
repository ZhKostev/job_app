require 'rails_helper'

RSpec.describe ReviewsFetcher do

  describe 'with search params' do
    let(:search_term) { 'test' }
    let(:search_params) { { :product_id => 42, :search_term => search_term } }
    let(:subject) { described_class.new(search_params) }
    let(:reviews) { [double(:id => 42), double(:id => 43)] }
    let(:reviews_parsed_data) do
      [
        { :title => 't1', :body => 'lorem ipsum 1' },
        { :title => 't2', :body => 'lorem ipsum 2' },
      ]
    end

    describe 'defaults' do
      it 'fetches walmart reviews by default' do
        expect(subject.review_source).to eq('Walmart')
      end

      it 'set errors to empty after initialization' do
        expect(subject.errors).to match_array([])
      end
    end

    describe 'validations' do
      it 'add error if product id is empty' do
        expect_any_instance_of(WalmartWebFetcher).not_to receive(:fetch)
        subject = described_class.new({ :search_term => search_term })
        expect(subject.success_fetch?).to eq(false)
        expect(subject.errors).to match_array(['Please enter product id'])
      end
    end

    describe '#fetch' do
      it 'search in the web only once' do
        expect_any_instance_of(WalmartWebFetcher).to receive(:fetch).and_return([])
        subject.send(:fetch)
        expect_any_instance_of(WalmartWebFetcher).not_to receive(:fetch)
        subject.send(:fetch)
      end

      it 'creates reviews' do
        allow(subject).to receive(:no_data_in_db?).and_return(true)
        expect_any_instance_of(WalmartWebFetcher).to receive(:fetch).and_return(reviews_parsed_data)
        expect{ subject.send(:fetch) }.to change{ Review.count }.by(2)
        lastest_review = Review.last
        expect(lastest_review.web_source).to eq('Walmart')
        expect(lastest_review.product_id).to eq('42')
      end
    end

    describe '#reviews' do
      it 'fetches records from DB if reviews already in DB' do
        expect_any_instance_of(WalmartWebFetcher).not_to receive(:fetch)
        allow(subject).to receive(:no_data_in_db?).and_return(false)
        ar_after_web_source_cond = double
        ar_after_product_id_cond = double
        expect(ar_after_product_id_cond).to receive(:where).
                                              with("title LIKE ? OR body LIKE ?", "%#{search_term}%", "%#{search_term}%").
                                              and_return(reviews)
        expect(ar_after_web_source_cond).to receive(:where).with({:product_id => search_params[:product_id]})
                                            .and_return(ar_after_product_id_cond)

        expect(Review).to receive(:where).with({ :web_source => 'Walmart' }).and_return(ar_after_web_source_cond)

        subject.reviews
      end

      it 'fetches from web if there are no reviews in DB' do
        expect_any_instance_of(WalmartWebFetcher).to receive(:fetch).and_return([])
        allow(subject).to receive(:no_data_in_db?).and_return(true)
        subject.reviews
      end
    end

    describe '#success_fetch?' do
      it 'returns false if there were some errors' do
        allow(subject).to receive(:errors).and_return(%w(1 2))
        allow(subject).to receive(:fetch).and_return(true)
        expect(subject.success_fetch?).to eq(false)
      end

      it "returns false if no errors collected" do
        allow(subject).to receive(:errors).and_return([])
        allow(subject).to receive(:fetch).and_return(true)
        expect(subject.success_fetch?).to eq(true)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe WalmartWebFetcher do
  include ActionDispatch::TestProcess
  let(:product_id) { 42 }
  let(:subject) { described_class.new(product_id) }

  describe 'initialization' do
    it 'sets current page to first after initialization' do
      expect(subject.current_page).to eq(1)
    end
  end

  describe '#fetch' do
    let(:page_pagination_html) { fixture_file_upload('/walmart/page_pagination.html').read }
    let(:last_page_pagination_html) { fixture_file_upload('/walmart/last_page_pagination.html').read }
    let(:reviews_html) { fixture_file_upload('/walmart/reviews.html').read }

    it 'fetch walmart reviews & parse page' do
      allow(subject).to receive(:open_page).with(1).and_return(last_page_pagination_html + reviews_html)
      expect(subject.fetch.size).to eq(2)
    end

    it 'fetcher walmart reviews & parse page even if there is no pagination on the page' do
      allow(subject).to receive(:open_page).with(1).and_return(reviews_html)
      expect(subject.fetch.size).to eq(2)
    end

    it 'fetches multiple pages' do
      allow(subject).to receive(:open_page).with(1).and_return(page_pagination_html + reviews_html)
      allow(subject).to receive(:open_page).with(2).and_return(last_page_pagination_html + reviews_html)
      expect(subject.fetch.size).to eq(4)
    end

    it 'returns empty data if there was no reviews on this product' do
      allow(subject).to receive(:open_page).with(1).and_return('<div>Some div</div>')
      expect(subject.fetch).to match_array([])
    end

    it 'has memoization' do
      allow(subject).to receive(:open_page).with(1).and_return(last_page_pagination_html + reviews_html)
      expect(subject.fetch.size).to eq(2)
      expect(subject).not_to receive(:open_page)
      expect(subject.fetch.size).to eq(2)
    end
  end
end

require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  describe 'index' do
    let(:fetcher_class) { ReviewsFetcher }
    it 'renders page if not search params present' do
      get :index
      expect(response).to be_success
    end

    describe 'with search params' do
      let(:search_params) { { :product_id => 42, :search_term => 'TEST' } }
      let(:reviews) { [double(:title => 'T1', :body => 'Lorem Ipsum'), double(:title => 'T2', :body => 'Lorem Ipsum')] }

      it 'renders page if request was successful, but no reviews found' do
        allow_any_instance_of(fetcher_class).to receive(:success_fetch?).and_return(true)
        allow_any_instance_of(fetcher_class).to receive(:reviews).and_return([])
        get :index, search_params
        expect(response).to be_success
      end

      it 'renders page if request was successful and some interviews were found' do
        allow_any_instance_of(fetcher_class).to receive(:success_fetch?).and_return(true)
        allow_any_instance_of(fetcher_class).to receive(:reviews).and_return(reviews)
        get :index, search_params
        expect(response).to be_success
      end

      it 'renders page if there was some validation errors' do
        allow_any_instance_of(fetcher_class).to receive(:success_fetch?).and_return(false)
        allow_any_instance_of(fetcher_class).to receive(:errors).and_return(%w(fake test))
        expect_any_instance_of(fetcher_class).not_to receive(:reviews)
        get :index, search_params
        expect(response).to be_success
      end
    end
  end
end

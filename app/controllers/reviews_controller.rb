class ReviewsController < ApplicationController
  def index
    @reviews_fetcher = ReviewsFetcher.new(params)
  end
end

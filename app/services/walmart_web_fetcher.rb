require 'nokogiri'
require 'open-uri'
class WalmartWebFetcher
  WALMART_REVIEWS_URL_TEMPLATE = 'https://www.walmart.com/reviews/product/:product_id'.freeze
  CSS_CLASS_FOR_REVIEW = '.customer-review-body'.freeze
  PAGINATION_LINK_SELECTOR = '.paginator-list li a'.freeze
  REVIEW_INNER_CSS_SELECTORS = {
    :title => '.customer-review-title',
    :body => '.js-customer-review-text'
  }.freeze

  attr_reader :product_id
  attr_accessor :current_page, :parsed_pages, :all_reviews_fetched
  def initialize(product_id)
    @product_id = product_id
    @parsed_pages = {}
    @current_page = 1
    @all_reviews_fetched = false
  end

  def fetch
    return @parsed_data if @parsed_data
    @parsed_data = []

    while !all_reviews_fetched do
      @parsed_data += fetch_reviews_from_walmart
      @current_page += 1
    end

    @parsed_data
  end

  private

  def fetch_reviews_from_walmart
    check_last_page
    fetch_reviews_from_page
  end

  def check_last_page
    last_pagination_link = parsed_reviews_page(current_page).css(PAGINATION_LINK_SELECTOR).last

    @all_reviews_fetched = last_pagination_link.nil? || last_pagination_link.attributes['class'].text =~ /active/
  end

  def fetch_reviews_from_page
    parsed_reviews_page(current_page).css(CSS_CLASS_FOR_REVIEW).map do |review_body|
      translate_body_to_attributes(review_body)
    end
  end

  def parsed_reviews_page(page_number = 1)
    parsed_pages[page_number] ||= Nokogiri::HTML(open(page_url(page_number)))
  end

  def page_url(page_number)
    WALMART_REVIEWS_URL_TEMPLATE.sub(':product_id', product_id) + '?page=' + page_number.to_s
  end

  #other attributes such as stars, customer etc can be extracted here.
  def translate_body_to_attributes(review_body)
    {
      :title => review_body.css(REVIEW_INNER_CSS_SELECTORS[:title]).text,
      :body => review_body.css(REVIEW_INNER_CSS_SELECTORS[:body]).text
    }
  end
end
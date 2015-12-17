class ReviewsFetcher
  attr_reader :search_term, :product_id
  attr_accessor :errors, :fetched

  def initialize(params)
    @search_term = params[:search_term]
    @product_id = params[:product_id]
    @errors = []
    @fetched = false
  end

  def reviews
    @reviews ||= fetch && search_reviews
  end

  def success_fetch?
    fetch && errors.empty?
  end

  private

  def fetch
    return true if fetched
    store_data_in_db(fetch_reviews_data_from_web) if valid_params? && no_data_in_db?
    fetched = true #do not fetch twice
  end

  def search_reviews
    Review.where(:product_id => product_id).where('title LIKE ? OR body LIKE ?', "%#{search_term}%", "%#{search_term}%")
  end

  #if there would be multiple sources this method should be changed
  def fetch_reviews_data_from_web
    WalmartWebFetcher.new(product_id).fetch
  end

  #pure SQL in order to speed up inserts. It can be done in various ways
=begin
  Review.connection.execute <<-SQL
      INSERT INTO reviews (title, body, web_source, product_id, created_at, updated_at)
        VALUES #{raw_values(parsed_data).join(", ")}
  SQL
=end
  def store_data_in_db(parsed_data)
    Review.transaction do
      parsed_data.each do |attrs|
        Review.create(attrs.merge(:product_id => product_id, :web_source => 'Walmart'))
      end
    end
  end

  #pure SQL in order to speed up inserts. It can be done in various ways
=begin
  def raw_values(parsed_data)
    timestamp = Time.zone.now.to_s(:db)

    parsed_data.map do |attrs|
      "('#{attrs[:title]}', '#{attrs[:body]}', 'Walmart', '#{product_id}', '#{timestamp}', '#{timestamp}')"
    end
  end
=end

  def no_data_in_db?
    Review.where(:product_id => product_id).empty?
  end

  # all possible validations goes here
  def valid_params?
    #errors << 'Please enter search term' if search_term.blank?
    errors << 'Please enter product id' if product_id.blank?

    errors.empty?
  end
end
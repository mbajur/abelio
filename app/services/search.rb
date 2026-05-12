class Search
  attr_reader :query

  def initialize(query)
    @query = query
  end

  def call
    if query.starts_with?("@")
      search_by_username
    elsif query.starts_with?("https://")
      search_by_url
    else
      search_by_content
    end
  end

  private

  def search_by_username
    Federails::Actor.find_or_create_by_account(query)
  end

  def search_by_url
    Fediverse::Request.dereference(query)
  end

  def search_by_content
    Post.local.where("content ILIKE ?", "%#{query}%")
  end
end

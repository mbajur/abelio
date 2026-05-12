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
    [ :actor, Federails::Actor.find_or_create_by_account(query) ]
  end

  def search_by_url
    object = Fediverse::Request.dereference(query)
    postable = Federails::Utils::Object.find_or_initialize!(object)
    postable.post ||= Post.new
    postable.save!
    [ :post, post ]
  end

  def search_by_content
    [ :posts, [ Post.local.where("content ILIKE ?", "%#{query}%") ] ]
  end
end

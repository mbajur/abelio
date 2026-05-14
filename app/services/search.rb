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
    post = Federails::Utils::Object.find_or_initialize!(object)
    post.save!
    [ :post, post ]
  end

  # @todo move that to fulltext search, db engine agnostic
  def search_by_content
    escaped_query = ActiveRecord::Base.sanitize_sql_like(query.to_s)
    pattern = "%#{escaped_query.downcase}%"

    [ :posts, Post.where("LOWER(content) LIKE ?", pattern).limit(10) ]
  end
end

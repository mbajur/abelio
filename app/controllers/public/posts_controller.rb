module Public
  class PostsController < ApplicationController
    include Pagy::Method

    allow_unauthenticated_access

    def index
      headers["Content-Type"] = "text/html"

      template = Liquid::Template.parse(current_site.template.markup)
      pagination, objects = pagy(current_site.posts.local_federails_entities.published.freshly_published_first)

      render plain: template.render!(
        "page_type" => "home",
        "site" => Public::SiteSerializer.new(current_site),
        "posts" => objects.map { |post| Public::PostSerializer.new(post) },
        "pagination" => Public::PaginationSerializer.new(pagination)
      )
    end

    def show
      headers["Content-Type"] = "text/html"

      template = Liquid::Template.parse(current_site.template.markup)
      post = current_site.posts.local_federails_entities.published.find(params[:id])

      render plain: template.render!(
        "page_type" => "post",
        "site" => Public::SiteSerializer.new(current_site),
        "post" => Public::PostSerializer.new(post),
      )
    end
  end
end

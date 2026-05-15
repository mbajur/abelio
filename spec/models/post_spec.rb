require "rails_helper"

RSpec.describe Post, type: :model do
  describe ".by_site_and_its_followings" do
    let(:site) { create(:site) }
    let(:followed_site) { create(:site) }
    let(:unfollowed_site) { create(:site) }

    before do
      # Create a follow relationship from site to followed_site
      Federails::Following.create!(
        actor: site.federails_actor,
        target_actor: followed_site.federails_actor
      )
    end

    it "includes posts from the site itself" do
      site_post = create(:post, site: site, federails_actor: site.federails_actor)
      create(:post, site: followed_site, federails_actor: followed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      expect(result).to include(site_post)
    end

    it "includes posts from followed sites" do
      create(:post, site: site, federails_actor: site.federails_actor)
      followed_post = create(:post, site: followed_site, federails_actor: followed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      expect(result).to include(followed_post)
    end

    it "excludes posts from unfollowed sites" do
      create(:post, site: site, federails_actor: site.federails_actor)
      create(:post, site: followed_site, federails_actor: followed_site.federails_actor)
      unfollowed_post = create(:post, site: unfollowed_site, federails_actor: unfollowed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      expect(result).not_to include(unfollowed_post)
    end

    it "includes both site and followed posts together" do
      site_post = create(:post, site: site, federails_actor: site.federails_actor)
      followed_post = create(:post, site: followed_site, federails_actor: followed_site.federails_actor)
      create(:post, site: unfollowed_site, federails_actor: unfollowed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      expect(result).to match_array([ site_post, followed_post ])
    end

    it "includes the federails_actor relation" do
      create(:post, site: site, federails_actor: site.federails_actor)
      create(:post, site: followed_site, federails_actor: followed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      # Verify the association is accessible
      expect(result.first.federails_actor).to be_present
      expect(result.last.federails_actor).to be_present
    end

    it "returns empty collection when site has no posts and no followings" do
      empty_site = create(:site)

      result = Post.by_site_and_its_followings(empty_site)

      expect(result).to be_empty
    end

    it "returns only site posts when site has no followings" do
      no_follow_site = create(:site)
      no_follow_post = create(:post, site: no_follow_site, federails_actor: no_follow_site.federails_actor)

      result = Post.by_site_and_its_followings(no_follow_site)

      expect(result).to contain_exactly(no_follow_post)
    end

    it "includes multiple posts from both site and followed actors" do
      site_post_1 = create(:post, site: site, federails_actor: site.federails_actor)
      site_post_2 = create(:post, site: site, federails_actor: site.federails_actor)
      followed_post_1 = create(:post, site: followed_site, federails_actor: followed_site.federails_actor)
      followed_post_2 = create(:post, site: followed_site, federails_actor: followed_site.federails_actor)

      result = Post.by_site_and_its_followings(site)

      expect(result).to match_array([ site_post_1, site_post_2, followed_post_1, followed_post_2 ])
    end
  end
end

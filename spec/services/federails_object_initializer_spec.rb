require "rails_helper"

RSpec.describe "Federails::Utils::Object postable initialization" do
  describe ".find_or_initialize!" do
    let(:note_hash) do
      {
        "id" => "https://remote.example.com/notes/1",
        "type" => "Note",
        "content" => "Note content",
        "summary" => "Note summary"
      }
    end

    let(:article_hash) do
      {
        "id" => "https://remote.example.com/articles/2",
        "type" => "Article",
        "name" => "Article title",
        "content" => "Article content",
        "summary" => "Article summary"
      }
    end

    before do
      allow(Fediverse::Request).to receive(:dereference) do |value|
        value
      end
      allow(Federails::Actor).to receive(:find_by_federation_url).and_return(nil)
      allow_any_instance_of(Post).to receive(:ensure_federails_configuration!).and_return(true)
      allow_any_instance_of(Post).to receive(:set_federails_actor).and_return(true)
    end

    it "initializes a Post with Note postable for incoming Note objects" do
      post = Federails::Utils::Object.find_or_initialize!(note_hash)

      expect(post).to be_a(Post)
      expect(post).to be_new_record
      expect(post.postable).to be_a(Note)
      expect(post.postable.content).to eq("Note content")
      expect(post.postable.summary).to eq("Note summary")
      expect(post.raw_data).to eq(note_hash)
    end

    it "initializes a Post with Article postable for incoming Article objects" do
      post = Federails::Utils::Object.find_or_initialize!(article_hash)

      expect(post).to be_a(Post)
      expect(post).to be_new_record
      expect(post.postable).to be_a(Article)
      expect(post.postable.name).to eq("Article title")
      expect(post.postable.content).to eq("Article content")
      expect(post.postable.summary).to eq("Article summary")
      expect(post.raw_data).to eq(article_hash)
    end

    it "finds an existing post for the same remote object id" do
      note = create(:note)
      site = create(:site)
      Post.insert_all!([
        {
          federated_url: note_hash["id"],
          postable_type: "Note",
          postable_id: note.id,
          site_id: site.id,
          state: "initialized",
          raw_data: note_hash,
          created_at: Time.current,
          updated_at: Time.current
        }
      ])
      first_post = Post.find_by!(federated_url: note_hash["id"])

      found_post = Federails::Utils::Object.find_or_initialize!(note_hash)

      expect(found_post).to be_persisted
      expect(found_post.id).to eq(first_post.id)
      expect(Post.where(federated_url: note_hash["id"]).count).to eq(1)
    end
  end
end

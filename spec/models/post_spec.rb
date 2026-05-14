require "rails_helper"

RSpec.describe Post, type: :model do
  describe "Federails data registration" do
    it "registers Post as a data handler for each handled ActivityPub type" do
      expect(Federails.data_entity_configuration(described_class)[:handles]).to eq(%w[Note Article])

      note_handlers = Federails.data_entity_handlers_for("Note")
      article_handlers = Federails.data_entity_handlers_for("Article")

      expect(note_handlers).to include(include(class: described_class))
      expect(article_handlers).to include(include(class: described_class))
    end

    it "registers inbox handlers for each handled ActivityPub type" do
      note_handlers = Fediverse::Inbox.send(:get_handlers, "Create", "Note")
      article_handlers = Fediverse::Inbox.send(:get_handlers, "Create", "Article")
      note_update_handlers = Fediverse::Inbox.send(:get_handlers, "Update", "Note")
      article_update_handlers = Fediverse::Inbox.send(:get_handlers, "Update", "Article")

      expect(note_handlers[described_class]).to eq(:handle_incoming_fediverse_data)
      expect(article_handlers[described_class]).to eq(:handle_incoming_fediverse_data)
      expect(note_update_handlers[described_class]).to eq(:handle_incoming_fediverse_data)
      expect(article_update_handlers[described_class]).to eq(:handle_incoming_fediverse_data)
    end
  end
end

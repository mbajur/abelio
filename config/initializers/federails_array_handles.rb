require "fediverse/inbox"

module Abelio
  module FederailsArrayHandlesPatch
    def data_entity_handlers_for(type)
      Federails::Configuration.data_types.select do |_, configuration|
        Array(configuration[:handles]).include?(type)
      end.map(&:last)
    end
  end

  module FediverseInboxArrayHandlesPatch
    def register_handler(activity_type, object_type, klass, method)
      Array(object_type).each do |single_object_type|
        super(activity_type, single_object_type, klass, method)
      end
    end
  end
end

Federails.singleton_class.prepend(Abelio::FederailsArrayHandlesPatch)
Fediverse::Inbox.singleton_class.prepend(Abelio::FediverseInboxArrayHandlesPatch)

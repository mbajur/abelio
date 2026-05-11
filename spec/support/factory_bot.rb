require 'factory_bot_rails'

RSpec.configure do |config|
  # FactoryBot is automatically included by factory_bot_rails
  # No need to redefine or find definitions
end

FactoryBot.definition_file_paths << Federails::Engine.root.join('spec', 'factories')
FactoryBot.reload

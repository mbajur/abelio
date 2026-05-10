template = Template.create! name: "Default", content: Rails.root.join("config", "default_template.liquid").read
site = Site.create! domain: "abelio-localhost", name: "Abelio", username: "abelio", template: template
User.create! email_address: "email@example.com", password: "TestPass123", site: site, username: "admin", name: "Abelio Admin"

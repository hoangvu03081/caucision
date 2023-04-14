FactoryBot.define do
  factory :project do
    id                { SecureRandom.uuid }
    name              { SecureRandom.alphanumeric }
    description       { SecureRandom.alphanumeric }
    data_imported     { false }
    user
  end
end

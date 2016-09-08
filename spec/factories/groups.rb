FactoryGirl.define do
  factory :group do
    name { Faker::Company.name }
    description { Faker::Lorem.paragraph }
    tags_list %w(tag1 tag2 tag3).join(',')
    interest_border_tkn { "P-#{Province.all.sample.id}" }

    default_role_name { Faker::Name.title }
    default_role_actions DEFAULT_GROUP_ACTIONS
    current_user_id { create(:user).id }

    # a factory for groups with the province inside an existing record
    factory :group_with_province do
      interest_border_tkn { "P-#{create(:province).id}" }
    end
  end
end

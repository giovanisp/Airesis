FactoryGirl.define do
  factory :proposal do
    proposal_category_id ProposalCategory::NO_CATEGORY
    title { Faker::Lorem.sentence }
    tags_list ['tag1', 'tag2', 'tag3'].join(',')
    association :quorum, factory: :best_quorum
    votation { {later: 'true'} }
    factory :public_proposal do
    end

    factory :group_proposal do
      association :group_proposals
      visible_outside true
    end

    after(:create) do
      Sunspot.commit
    end
  end
end

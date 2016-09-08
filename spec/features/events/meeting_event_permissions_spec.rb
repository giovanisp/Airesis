require 'spec_helper'
require 'requests_helper'
require 'cancan/matchers'

describe 'check permissions on meeting events', type: :feature, seeds: true do
  let!(:user) { create(:user) }
  let!(:group) { create(:group, current_user_id: user.id) }
  let!(:event) { create(:meeting_event, user: user) }
  let!(:meeting_organization) { create(:meeting_organization, event: event, group: group) }
  let!(:meeting) { create(:meeting, event: event) }
  let!(:ability) { Ability.new(user) }
  let!(:user2) { create(:user) }
  let!(:user3) { create(:user) }
  let!(:user4) { create(:user) }
  let!(:group2) { create(:group, current_user_id: user2.id) }
  before :each do
    create_participation(user2, group)
    create_participation(user3, group)
    create_participation(user4, group)

    # user2 is also administrator of group2

    expect(group.scoped_participants(GroupAction::STREAM_POST).count).to eq 4
    expect(group.scoped_participants(GroupAction::CREATE_EVENT).count).to eq 4
    expect(group.scoped_participants(GroupAction::PROPOSAL_DATE).count).to eq 4
  end

  it 'manage correctly the permissions on meeting events' do
    # can manage his event
    expect(ability).to be_able_to(:read, event)
    expect(ability).to be_able_to(:edit, event)
    expect(ability).to be_able_to(:update, event)
    expect(ability).to be_able_to(:destroy, event)

    # the participants can not (but they see it)
    expect(Ability.new(user2)).to be_able_to(:read, event)
    expect(Ability.new(user2)).not_to be_able_to(:edit, event)
    expect(Ability.new(user2)).not_to be_able_to(:update, event)
    expect(Ability.new(user2)).not_to be_able_to(:destroy, event)

    # events by user2 can be edited both by admin and user2 but not by user3 and 4
    event2 = create(:meeting_event, user: user2)
    create(:meeting_organization, event: event2, group: group)
    create(:meeting, event: event2)

    # admin can manage the event
    expect(ability).to be_able_to(:read, event2)
    expect(ability).to be_able_to(:edit, event2)
    expect(ability).to be_able_to(:update, event2)
    expect(ability).to be_able_to(:destroy, event2)

    # he can manage his event
    expect(Ability.new(user2)).to be_able_to(:read, event2)
    expect(Ability.new(user2)).to be_able_to(:edit, event2)
    expect(Ability.new(user2)).to be_able_to(:update, event2)
    expect(Ability.new(user2)).to be_able_to(:destroy, event2)

    # not logged user cannot see the event
    expect(Ability.new(nil)).to_not be_able_to(:read, event2)

    # another participant can see it but not edit it
    expect(Ability.new(user3)).to be_able_to(:read, event2)
    expect(Ability.new(user3)).to_not be_able_to(:edit, event2)
    expect(Ability.new(user3)).to_not be_able_to(:update, event2)
    expect(Ability.new(user3)).to_not be_able_to(:destroy, event2)
  end
end

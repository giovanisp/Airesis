require 'spec_helper'

describe 'events/show.html.erb' do
  include Devise::TestHelpers

  context 'votation event' do
    let(:event) {create(:vote_event)}

    before(:each) do
      proposals = create_list(:in_vote_public_proposal, 3)
      proposals.each do |proposal|
        proposal.update_columns(vote_period_id: event.id)
      end
      assign(:event, event)
      assign(:proposals, event.proposals.for_list)
    end

    it 'displays the page correctly' do
      render
      expect(rendered).to include event.title
    end
  end
end

require 'spec_helper'
require 'requests_helper'
require 'cancan/matchers'

describe "create a proposal in his group", type: :feature, js: true, ci_ignore: true  do

  let!(:user) { create(:user) }
  let!(:group) { create(:group, current_user_id: user.id) }
  let!(:proposal) { create(:group_proposal, quorum: group.quorums.active.first, current_user_id: user.id, group_proposals: [GroupProposal.new(group: group)]) }

  before :each do
    login_as user, scope: :user
  end

  after :each do
    logout(:user)
  end

  it "creates the proposal in group" do
    visit new_group_proposal_path(group)

    proposal_name = Faker::Lorem.sentence
    within("#main-copy") do
      fill_in I18n.t('pages.proposals.new.title_synthetic'), with: proposal_name
      fill_tokeninput '#proposal_tags_list', with: ['tag1', 'tag2', 'tag3']
      fill_in_ckeditor 'proposal_sections_attributes_0_paragraphs_attributes_0_content', with: Faker::Lorem.paragraph
      select2("15 giorni", xpath: "//div[@id='s2id_proposal_quorum_id']")
      wait_for_ajax
      click_button I18n.t('pages.proposals.new.create_button')
    end
    page_should_be_ok
    wait_for_ajax rescue nil
    @proposal = Proposal.last

    expect(@proposal.vote_defined).to be_truthy
    #the proposal title is certainly displayed somewhere
    expect(page).to have_content @proposal.title
    expect(page.current_path).to eq(edit_group_proposal_path(group, @proposal))

    page.execute_script 'window.confirm = function () { return true }'
    page.execute_script 'safe_exit = true;'
    within_left_menu do
      click_link I18n.t('buttons.cancel')
    end

    expect(page).to have_content @proposal.title
    within("#menu-left") do
      expect(page).to have_content(I18n.t('proposals.show.ready_for_vote'))
      expect(page).to have_content(I18n.t('proposals.show.keep_discuss'))
    end

  end


  def simple_editing
    visit edit_group_proposal_path(group, proposal)
    sleep 2
    new_content = Faker::Lorem.paragraph

    fill_in_ckeditor 'proposal_sections_attributes_0_paragraphs_attributes_0_content_dirty', with: new_content

    within_left_menu do
      click_link I18n.t('buttons.update')
    end
    expect(page.current_path).to eq group_proposal_path(group, proposal)
    expect(page).to have_content(new_content)
  end

  it "can edit a proposal", ci_ignore: true do
    simple_editing
  end

  it "evaluation of a proposal by the author and other users" do

    def vote_and_check
      pressed = I18n.t('proposals.show.ready_for_vote')
      other = I18n.t('proposals.show.keep_discuss')
      within("#menu-left") do
        expect(page).to have_content(pressed)
        expect(page).to have_content(other)
        click_link pressed
      end

      expect(page).to have_content(I18n.t('info.proposal.rank_recorderd'))

      within("#menu-left") do
        expect(find_link(pressed)[:href]).to eq '#'
        expect(page).to_not have_link(other)
      end
    end

    def second_vote_and_check
      pressed = I18n.t('proposals.show.ready_for_vote')
      other = I18n.t('proposals.show.keep_discuss')
      within("#menu-left") do
        expect(find_link(pressed)[:href]).to eq '#'
        expect(page).to have_content(other)
        click_link other #change ides
      end

      expect(page).to have_content(I18n.t('info.proposal.rank_recorderd'))

      within("#menu-left") do
        expect(find_link(other)[:href]).to eq '#'
        expect(page).to_not have_link(pressed)
      end
    end

    visit group_proposal_path(group, proposal)
    expect(page.current_path).to eq group_proposal_path(group, proposal)

    vote_and_check
    logout(:user)
    how_many = 3
    other_users = []
    how_many.times do |i|
      user2 = create(:user)
      other_users << user2
      create_participation(user2, group)
      login_as user2, scope: :user
      visit group_proposal_path(group, proposal)

      vote_and_check

      proposal.reload
      expect(proposal.valutations).to eq (i+1)+1
      expect(Ability.new(user2)).to_not be_able_to(:rank_up, proposal)
      logout(:user)
    end

    group.reload

    expect(group.participants.count).to eq how_many+1

    proposal.current_user_id = user.id

    new_title = Faker::Lorem.sentence
    proposal.update(title: new_title)

    login_as user, scope: :user

    expect(Ability.new(user)).to be_able_to(:rankup, proposal)
    expect(Ability.new(user)).to be_able_to(:rankdown, proposal)

    visit group_proposal_path(group, proposal)

    second_vote_and_check

    proposal.reload

    expect(proposal.valutations).to eq(how_many+1)
    expect(proposal.rank).to eq (how_many.to_f/(how_many+1).to_f)*100

    logout :user
    how_many.times do |i|
      login_as other_users[i], scope: :user
      visit group_proposal_path(group, proposal)
      second_vote_and_check
      proposal.reload
      expect(proposal.valutations).to eq(how_many+1)
      expect(proposal.rank).to eq ((how_many - (1+i)).to_f/(how_many+1).to_f)*100
      expect(Ability.new(other_users[i])).to_not be_able_to(:rank_down, proposal)
      logout :user
    end
  end

  ProposalType.active.for_groups.order(:seq).each_with_index do |proposal_type, index|
    it "creates a #{proposal_type.name} proposal in group through dialog window" do
      visit group_proposals_path(group)
      within('.menu-left') do
        click_link I18n.t('proposals.create_button')
      end
      find("div[data-id=#{proposal_type.name}]").click

      proposal_name = Faker::Lorem.sentence
      within(".reveal-modal") do
        fill_in I18n.t('pages.proposals.new.title_synthetic'), with: proposal_name
        click_button I18n.t('buttons.next')
        fill_tokeninput '#proposal_tags_list', with: ['tag1', 'tag2', 'tag3']
        click_button I18n.t('buttons.next')
        fill_in_ckeditor 'proposal_sections_attributes_0_paragraphs_attributes_0_content', with: Faker::Lorem.paragraph
        click_button I18n.t('buttons.next')
        select2("15 giorni", xpath: "//div[@id='s2id_proposal_quorum_id']")
        sleep 2
        click_button I18n.t('pages.proposals.new.create_button')
      end
      page_should_be_ok
      sleep 2
      proposal2 = Proposal.order(created_at: :desc).first
      expect(page.current_path).to eq(edit_group_proposal_path(group, proposal2))
      if index == 2
        visit edit_group_proposal_path(group, proposal2)
        expect(page).to have_content proposal2.title

        page.execute_script 'window.confirm = function () { return true }'
        page.execute_script 'safe_exit = true;'
        wait_for_ajax
        within_left_menu do
          click_link I18n.t('buttons.cancel')
        end
        expect(page).to have_content proposal2.title
      end
    end
  end
end

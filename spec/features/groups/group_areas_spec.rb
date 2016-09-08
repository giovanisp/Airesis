require 'spec_helper'
require 'requests_helper'

describe 'the management of group areas', type: :feature, js: true, seeds: true do
  before :each do
    @user = create(:user)
    @ability = Ability.new(@user)
    @group = create(:group, current_user_id: @user.id)
    login_as @user, scope: :user
  end

  after :each do
    logout :user
  end

  it 'can activate areas' do
    visit group_group_areas_path(@group)
    page_should_be_ok
    click_link I18n.t('pages.groups.edit_work_areas.index.enable')
    page_should_be_ok
    expect(page.current_path).to eq(group_group_areas_path(@group))
    expect(page).to_not have_content(I18n.t('pages.groups.edit_work_areas.index.enable'))
  end

  it 'can manage group areas' do
    @group.update_attributes(enable_areas: true)
    visit new_group_group_area_path(@group)
    role_name = Faker::Name.title
    within('#main-copy') do
      fill_in I18n.t('activerecord.attributes.group_area.name'), with: role_name
      fill_in I18n.t('activerecord.attributes.group_area.description'), with: Faker::Lorem.sentence
      fill_in I18n.t('activerecord.attributes.group_area.default_role_name'), with: Faker::Name.title
      click_button I18n.t('buttons.create')
    end
    expect(page).to have_content role_name
    @group_area = GroupArea.order(created_at: :desc).first
    expect(page.current_path).to eq(group_group_area_path(@group, @group_area))
  end

  it 'can manage users inside a group area' do
    @group.update_attributes(enable_areas: true)
    group_area = create(:group_area, group: @group)
    visit group_group_area_path(@group, group_area)
  end
end

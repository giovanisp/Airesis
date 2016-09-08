class Search < ActiveRecord::Base
  attr_accessor :groups, :proposals, :user_id, :blogs

  def find
    user = User.find(user_id)
    groups_a = user.portavoce_groups.pluck(:id)
    groups_b = user.groups.pluck(:id) - groups_a # don't boost for both

    self.groups = Group.search do
      fulltext "#{q}*" do
        boost(20.0) { with(:id, groups_a) }
        boost(10.0) { with(:id, groups_b) }
      end

      order_by :score, :desc
      order_by :group_participations_count, :desc
      order_by :created_at, :desc

      paginate page: 1, per_page: 5
    end.results

    list_a = user.proposals.pluck('proposals.id')
    list_b = user.partecipating_proposals.pluck('proposals.id') - list_a # don't boosts for both please

    self.proposals = Proposal.search do
      fulltext q do
        boost(30.0) { with(:id, list_a) } # good boost for my proposals
        boost(20.0) { with(:id, list_b) } # boost for proposals i'm partecipating
        boost(10.0) { with(:group_ids, user.groups.pluck(:id)) } # take a boost for proposals in my groups
      end
      all_of do
        without(:proposal_type_id, 11) # TODO: removed petitions
        any_of do
          with(:private, false)
          with(:visible_outside, true)
          if user_id
            all_of do
              with(:group_ids, User.find(user_id).groups.pluck(:id))
              with(:presentation_area_ids, nil)
              # TODO: doesn't find proposals in group areas yet
            end
          end
        end
      end

      # adjust_solr_params do |params|
      #  params[:bq] = " group_ids_im:(#{User.find(self.user_id).groups.pluck(:id).join(' OR ')})^20"
      # end
      # order_by :group_ids, :desc
      order_by :score, :desc
      order_by :updated_at, :desc
      paginate page: 1, per_page: 5
    end.results

    self.blogs = Blog.search do
      fulltext q
      order_by :score, :desc
      paginate page: 1, per_page: 5
    end.results
  end
end

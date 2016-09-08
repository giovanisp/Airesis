class ParagraphHistory < ActiveRecord::Base
  belongs_to :section, class_name: 'SectionHistory'

  # we remove title and username
  def parsed_content(anonimous = true)
    if anonimous
      users = []
      content.gsub(/data-userid="([^".]+)"/) do |match| #
        users << User.find(Regexp.last_match(1)) rescue nil
        match
      end
      ret = content
      users.each do |user|
        fullname = user.fullname
        nickname = ProposalNickname.where(proposal_id: proposal_id, user_id: user.id).first.nickname
        ret = ret.gsub(fullname, nickname)
      end
      return ret
    end
    content
  end
end

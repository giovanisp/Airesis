class ProposalCommentReportType < ActiveRecord::Base
  LOW = 0
  HIGH = 1

  has_many :proposal_comment_reports, class_name: 'ProposalCommentReport'

  scope :softs, -> { where(severity: ProposalCommentReportType::LOW).order(:seq) }
  scope :graves, -> { where(severity: ProposalCommentReportType::HIGH).order(:seq) }
end

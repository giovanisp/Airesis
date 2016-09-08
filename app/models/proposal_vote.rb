class ProposalVote < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :user

  def number
    positive + negative + neutral
  end

  def positive_perc
    perc(positive)
  end

  def negative_perc
    perc(negative)
  end

  def neutral_perc
    perc(neutral)
  end

  protected

  def perc(value)
    number > 0 ? ((value.to_f / number.to_f) * 100).round(2) : 0
  end
end

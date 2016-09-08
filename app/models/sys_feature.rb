class SysFeature < ActiveRecord::Base
  has_many :sys_payment_notifications, as: :payable

  has_attached_file :image,
                    styles: {
                      medium: '300x300>'
                    },
                    path: 'sys_features/:id/:style/:basename.:extension'

  validates_attachment_content_type :image, content_type: ['image/jpeg', 'image/png', 'image/gif']

  def amount_received_calc
    sys_payment_notifications.sum(:payment_gross)
  end
end

#encoding: utf-8
class DeleteOldNotifications
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence { daily.hour_of_day(1) }
  sidekiq_options queue: :low_priority


  def perform(*args)
    msg = "Cancella vecchie notifiche\n"
    count = 0
    deleted = Notification.destroy_all(["created_at < ?", 6.months.ago])
    msg +="Cancello " + deleted.count.to_s + " notifiche più vecchie di 6 mesi"
    count += deleted.count
    read = Notification.destroy_all(["notifications.id not in (
                                              select n.id
                                              from notifications n
                                              join alerts ua
                                              on n.id = ua.notification_id
                                              where ua.checked = FALSE)
                                              and created_at < ?", 1.month.ago])
    msg +="Cancello " + read.count.to_s + " notifiche già lette più vecchie di 1 mese"
    puts read.count
    count += read.count
    ResqueMailer.delay.admin_message(msg)
    count
  end

end

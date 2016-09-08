class AlertsController < ApplicationController
  before_filter :authenticate_user!

  layout 'users'

  load_and_authorize_resource except: [:check_all, :proposal], through: :current_user

  helper_method :calculate_alert_path

  def index
    respond_to do |format|
      format.html do
        @user = current_user
        @page_title = 'All alerts'
        @new_alerts = @alerts.where(checked: false)
        @old_alerts = @alerts.where(checked: true)
      end
      format.json do
        unread = @alerts.where(checked: false, deleted: false).
          includes(:notification_type, :notification_category)
        numunread = unread.length
        if numunread < 10
          unread += @alerts.where(checked: true, deleted: false).
            includes(:notification_type, :notification_category).limit(10 - numunread)
        end

        alerts = unread.map do |alert|
          { id: alert.id,
            path: calculate_alert_path(alert),
            created_at: (time_in_words alert.created_at),
            checked: alert.checked,
            text: alert.message,
            proposal_id: alert.data[:proposal_id],
            category_name: alert.notification_category.short.downcase,
            category_title: alert.notification_category.description.upcase,
            image: alert.image_url }
        end
        @map = { count: numunread, alerts: alerts }
        render json: @map
      end
    end
  end

  # sign as read an alert and redirect to corresponding url
  def check
    @alert = current_user.admin? ? Alert.find(params[:id]) : current_user.alerts.find_by(id: params[:id])
    @alert.check!

    respond_to do |format|
      format.html { redirect_to calculate_alert_path(@alert) }
      format.js { render nothing: true }
    end
  rescue Exception => e
    @title = 'Impossibile recuperare la notifica' # TODO: I18n
    @message = "Probabilmente hai più di un account su Airesis e non sei autenticato con quello a cui è destinata la notifica<br/>Esci ed entra con l'account corretto."
    render template: '/errors/404', status: 404, layout: true
  end

  # check all notifications

  def check_all
    current_user.unread_alerts.check_all
    respond_to do |format|
      format.js { render nothing: true }
    end
  end

  # return notification tooltip for a specific proposal and user
  def proposal
    @proposal_id = params[:proposal_id]
    @unread = current_user.alerts.where(["(notifications.properties -> 'proposal_id') = ? and alerts.checked = ?", @proposal_id.to_s, false])
    render layout: false
  end

  protected

  def calculate_alert_path(alert)
    url = alert.checked ? alert.notification.url : check_alert_url(alert)
    uri = URI.parse(url)
    if params[:l]
      new_query_ar = URI.decode_www_form(uri.query || '') << ['l', params[:l]]
      uri.query = URI.encode_www_form(new_query_ar)
    end
    uri.to_s
  end
end

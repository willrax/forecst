module FC
  module Notification
    module_function

    def send(notification)
      notification_center.deliverNotification(notification)
    end

    def notification_center
      @notification_center ||= NSUserNotificationCenter.defaultUserNotificationCenter
      @notification_center.setDelegate(self)
    end

    def userNotificationCenter(center, shouldPresentNotification: notification)
      true
    end

    def userNotificationCenter(center, didActivateNotification: notification)
      open_forecast
    end

    def open_forecast
      location = App::Persistence[:location]

      url = NSURL.URLWithString("http://forecast.io/#/f/#{location}")
      NSWorkspace.sharedWorkspace.openURL(url)
      FC::Mixpanel.event("notification_clicked")
    end
  end
end

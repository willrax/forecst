class AppDelegate
  def applicationDidFinishLaunching(notification)
    NSWorkspace.sharedWorkspace.notificationCenter.addObserver(self, selector: "wake_from_sleep:",
                                                               name: NSWorkspaceDidWakeNotification, object: nil)
    set_preferences
    build_status_menu
    get_location_and_check_weather
    set_weather_timer
    FC::Mixpanel.event("open")
  end

  def set_preferences
    App::Persistence["interval"] = 3600 if App::Persistence["interval"].nil?
    App::Persistence["significant"] = false if App::Persistence["significant"].nil?
  end

  def set_weather_timer
    interval = App::Persistence[:interval]
    EM.cancel_timer(@weather_timer)

    puts "#{interval} timer set"

    @weather_timer = EM.add_periodic_timer interval do
      puts "#{interval} timer fired"
      get_location_and_check_weather
    end
  end

  def get_location_and_check_weather
    FC::Location.get do |response|
      if response["error"] != nil
        FC::Alert.send(response["error"], response["message"])
        @current_cond.setTitle(response["error"])
      else
        retrieve_weather(response)
      end
    end
  end

  def retrieve_weather(current_location)
    FC::Weather.get(current_location) do |current, next_hour, units|
      prepare_weather_notification(current, next_hour, units)
    end
  end

  def prepare_weather_notification(current, next_hour, units)
    current_conditions = "#{current["temperature"]}º#{units} and #{current["summary"]}"
    forecast_conditions = "#{next_hour["temperature"]}º#{units} and #{next_hour["summary"]}"

    notification = NSUserNotification.alloc.init
    notification.title = current_conditions
    notification.informativeText = "Next hour: #{forecast_conditions}"

    if App::Persistence[:significant] == true
      if next_hour["summary"] != current["summary"]
      puts "Conditions changed. Sending notification"
        FC::Notification.send(notification)
      else
        puts "Skipping notification with no condition change"
      end
    else
      puts "Sending notification"
      FC::Notification.send(notification)
    end

    update_status_conditions(current, current_conditions, forecast_conditions, units)
  end

  def update_status_conditions(current, current_conditions, forecast_conditions, units)
    @current_cond.setTitle("Current: #{current_conditions}")
    @forecast_cond.setTitle("Next hour: #{forecast_conditions}")
    @item.setTitle("#{current["temperature"].to_i}º#{units}")
    puts "Status menu updated"
  end

  # Delegate methods.

  def wake_from_sleep(notice)
    puts "Waking from sleep"
    EM.cancel_timer(@weather_timer)
    EM.cancel_timer(@change_timer)

    EM.add_periodic_timer 20 do
      get_location_and_check_weather
    end
  end
end

module FC
  module Weather
    module_function

    def get(location, &block)
      @callback = block

      BW::HTTP.get("https://api.forecast.io/forecast/APIKEY/#{location}?units=auto&exclude=[minutely,daily]") do |response|
        if response.ok?
          json = BW::JSON.parse(response.body.to_s)
          current = json["currently"]
          next_hour = json["hourly"]["data"][1]
          units = find_units(json["flags"]["units"])

          @callback.call(current, next_hour, units)
          FC::Mixpanel.event("weather_success")
        else
          notification = NSUserNotification.alloc.init
          notification.title = "Error"
          notification.informativeText = "There was an error retrieving the lastest weather report."

          FC::Notification.send(notification)
          FC::Mixpanel.event("weather_failure")
        end
      end
    end

    def find_units(unit)
      case unit
      when "si" || "ca" || "uk"
        "c"
      when "us"
        "f"
      end
    end
  end
end

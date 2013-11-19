module FC
  module Mixpanel
    module_function

    def event(event)
      json = {
        "event" => "#{event}",
        "properties" => {
          "time" => "#{Time.now}",
          "token" => "TOKEN"
        },
      }

      json = BW::JSON.generate(json)
      encoded_data = ["#{json}"].pack("m0")
      BW::HTTP.post("http://api.mixpanel.com/track?data=#{encoded_data}")
    end

    def action(event, action)
      json = {
        "event" => "#{event}",
        "properties" => {
          "time" => "#{Time.now}",
          "token" => "TOKEN",
          "action" => "#{action}"
        },
      }

      json = BW::JSON.generate(json)
      encoded_data = ["#{json}"].pack("m0")
      BW::HTTP.post("http://api.mixpanel.com/track?data=#{encoded_data}")
    end
  end
end

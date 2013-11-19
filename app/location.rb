module FC
  module Location
    module_function

    def get(&block)
      @callback = block
      puts "Calling Location"
      location_manager.startUpdatingLocation
    end

    def location_manager
      @location_manager ||=
        begin
          manager = CLLocationManager.alloc.init
          manager.delegate ||= self
          manager
        end
    end

    def locationManager(manager, didUpdateToLocation: new_location, fromLocation: old_location)
      location_manager.stopUpdatingLocation
      puts "Location recieved"
      coordinates = new_location.coordinate
      location = "#{coordinates.width},#{coordinates.height}"
      App::Persistence[:location] = location
      @callback.call(location)
    end

    def locationManager(manager, didFailWithError: error)
      puts "Error recieved"
      location_manager.stopUpdatingLocation

      case error.code
      when 0 then raise_error("Location Unknown", "We weren't able to discover your location. Check that your AirPort is on and that you're in range of some networks.")
      else
        raise_error("Unknown Error Occured", "An unknown error has occured: code #{error.code}")
      end
    end

    def raise_error(type, message)
      @callback.call({ "error" => type, "message" => message })
      @callback = nil
    end
  end
end

class AppDelegate
  def build_status_menu
    @statusBar = NSStatusBar.systemStatusBar
    @item = @statusBar.statusItemWithLength(NSVariableStatusItemLength)

    image = NSImage.imageNamed "temp"
    image.setSize(NSMakeSize(16, 16))

    @item.retain
    @item.setImage image
    @item.setHighlightMode(true)
    @item.setMenu(menu)
  end

  def menu
    @menu = NSMenu.new
    @menu.title = "Weather"

    @current_cond = NSMenuItem.new
    @current_cond.title = "Fetching..."

    @forecast_cond = NSMenuItem.new
    @forecast_cond.title = ""

    thirty_mins = NSMenuItem.new
    thirty_mins.title = "30 minutes"
    thirty_mins.setRepresentedObject(1800)
    thirty_mins.action = "set_interval:"

    one_hour = NSMenuItem.new
    one_hour.title = "1 hour"
    one_hour.setRepresentedObject(3600)
    one_hour.action = "set_interval:"

    two_hours = NSMenuItem.new
    two_hours.title = "2 hours"
    two_hours.setRepresentedObject(7200)
    two_hours.action = "set_interval:"

    @interval_menu = NSMenu.new
    @interval_menu.addItem thirty_mins
    @interval_menu.addItem one_hour
    @interval_menu.addItem two_hours

    significant = NSMenuItem.new
    significant.title = "Only if conditions change"
    significant.setRepresentedObject("significance")
    significant.action = "set_significant:"

    @notification_menu = NSMenu.new
    @notification_menu.addItem significant

    notification_sub = NSMenuItem.new
    notification_sub.title = "Notifications..."
    notification_sub.setSubmenu @notification_menu

    main = NSMenuItem.new
    main.title = "Update Interval..."
    main.setSubmenu @interval_menu

    help = NSMenuItem.new
    help.title = "Help"
    help.action = "open_help"

    forecast = NSMenuItem.new
    forecast.title = "Powered by forecast.io"
    forecast.action = "open_forecast"

    quit = NSMenuItem.new
    quit.title = "Quit"
    quit.action = "terminate:"

    @menu.addItem @current_cond
    @menu.addItem @forecast_cond
    @menu.addItem NSMenuItem.separatorItem
    @menu.addItem main
    @menu.addItem notification_sub
    @menu.addItem NSMenuItem.separatorItem
    @menu.addItem help
    @menu.addItem forecast
    @menu.addItem quit

    change_checkmark
    @menu
  end

  def open_forecast
    url = NSURL.URLWithString("http://forecast.io/")
    NSWorkspace.sharedWorkspace.openURL(url)
    FC::Mixpanel.event("open_forecast")
  end

  def open_help
    url = NSURL.URLWithString("http:///example.com")
    NSWorkspace.sharedWorkspace.openURL(url)
    FC::Mixpanel.event("open_help")
  end

  def set_interval(sender)
    interval_requested = sender.representedObject

    App::Persistence["interval"] = interval_requested
    FC::Mixpanel.action("interval_change", interval_requested)

    EM.cancel_timer(@weather_timer)
    EM.cancel_timer(@change_timer)

    puts "Cancelled existing timers"

    @change_timer = EM.add_timer(60) { get_location_and_check_weather }

    puts "Added change timer"

    set_weather_timer
    change_checkmark
  end

  def set_significant(sender)
    significant = App::Persistence["significant"]

    if significant == true
      App::Persistence["significant"] = false
      FC::Mixpanel.action("significance_change", "on")
    else
      App::Persistence["significant"] = true
      FC::Mixpanel.action("significance_change", "off")
    end

    change_checkmark
  end

  def change_checkmark
    @interval_menu.itemArray.each do |item|
      item.setState(NSOffState)
      item.setState(NSOnState) if item.representedObject == App::Persistence["interval"]
    end

    @notification_menu.itemArray.each do |item|
      if item.representedObject == "significance"
        item.setState(NSOffState)
        item.setState(NSOnState) if App::Persistence["significant"] == true
      end
    end
  end
end

# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require "motion/project/template/osx"
require "bundler"
require "bubble-wrap/reactor"

Bundler.require

Motion::Project::App.setup do |app|
  app.name = "Forecst"
  app.icon = "icon.icns"

  app.version = "1.2"
  app.short_version = "1"
  app.identifier = "com.willrax.forecst"

  app.info_plist["LSApplicationCategoryType"] = "public.app-category.weather"
  app.info_plist["NSUIElement"] = 1

  app.entitlements["com.apple.security.app-sandbox"] = true
  app.entitlements["com.apple.security.personal-information.location"] = true
  app.entitlements["com.apple.security.network.client"] = true

  app.frameworks += ["CoreLocation", "Security"]

  app.detect_dependencies = false
  app.deployment_target = "10.8"
  app.sdk_version = "10.8"
end

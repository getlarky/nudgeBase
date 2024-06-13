

Pod::Spec.new do |s|


  s.name         = "KeyValueStore"
  s.version      = "1.0.2"
  s.summary      = "KeyValueStore for Larky"

  s.description  = "The KeyValueStore for Larky"

  s.homepage     = "https://github.com/getlarky/keyValueStore-specs"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license      = { :type => '1 Custom', :text => "<<-LICENSE Copyright (c) 2023, Larky, Inc. Please contact Larky (support@larky.com) for licensing details. LICENSE" }


  s.author             = { "Larky, Inc." => "email@address.com" }
  # Or just: spec.author    = "Larky, Inc."
  # s.social_media_url   = "https://twitter.com/Larky, Inc."


  # s.platform     = :ios
  # s.platform     = :ios, "5.0"

  s.source       = { :http => 'https://github.com/getlarky/nudgePods/releases/download/nudgeBase-1.2.2/nudgeBase.zip' }
  
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'


  s.source_files  = "nudgeBase/Sources/KeyValueStore/*.{swift}"
  s.exclude_files = "Classes/Exclude"

end

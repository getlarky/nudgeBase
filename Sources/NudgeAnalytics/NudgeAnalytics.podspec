#
# Be sure to run `pod lib lint NudgeAnalytics.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NudgeAnalytics'
  s.version          = '1.0.2'
  s.summary          = 'NudgeAnalytics provides tools for recording metrics data '
  s.description      = 'NudgeAnalytics provides tools for recording metrics data, based on Segment.io. '

  s.homepage         = 'https://github.com/getlarky/nudgeAnalytics-specs'
  s.license          = { :type => '1 Custom', :text => "<<-LICENSE Copyright (c) 2023, Larky, Inc. Please contact Larky (support@larky.com) for licensing details. LICENSE" }
  s.author           = { 'connorlarky' => 'connor@larky.com' }
  s.source           = { :http => 'https://github.com/getlarky/nudgePods/releases/download/nudgeBase-1.2.2/nudgeBase.zip'}

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'nudgeBase/Sources/NudgeAnalytics/*.{swift}'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Analytics', '4.1.2'
  s.dependency 'EnvironmentUtils', '1.0.1'
  s.dependency 'KeyValueStore', '1.0.2'
end

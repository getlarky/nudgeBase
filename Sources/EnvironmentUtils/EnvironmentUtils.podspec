#
# Be sure to run `pod lib lint EnvironmentUtils.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EnvironmentUtils'
  s.version          = '1.0.1'
  s.summary          = 'EnvironmentUtils provides development utilities'
  s.description      = 'EnvironmentUtils provides utilities primarily for use during development'

  s.homepage         = 'https://github.com/getlarky/environmentUtils-specs'
  s.license          = { :type => '1 Custom', :text => "<<-LICENSE Copyright (c) 2023, Larky, Inc. Please contact Larky (support@larky.com) for licensing details. LICENSE" }
  s.author           = { 'connorlarky' => 'connor@larky.com' }
  s.source           = { :http => 'https://github.com/getlarky/nudgePods/releases/download/nudgeBase-1.2.2/nudgeBase.zip'}

  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'nudgeBase/Sources/EnvironmentUtils/*.{swift}'
  # s.frameworks = 'UIKit', 'MapKit'
end

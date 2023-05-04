# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def rx_pods
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
end

def swifty_draw
  pod 'SwiftyDraw', :git => 'https://github.com/mrazam110/SwiftyDraw.git'
end

workspace 'RiriApp'

target 'RiriApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  swifty_draw
  rx_pods
  
  target 'RiriAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'RiriAppUITests' do
    # Pods for testing
  end

end

target 'Common' do
  project '../RiriApp/Common/Common'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  swifty_draw
end

target 'Core' do
  project '../RiriApp/Core/Core'
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  rx_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
      config.build_settings["ENABLE_BITCODE"] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end

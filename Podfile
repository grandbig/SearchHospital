# Podfile
use_frameworks!
platform :ios, '11.0'

target "SearchHospital" do
  # Normal libraries
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'Moya'
  pod 'SwiftyJSON'

  abstract_target 'Tests' do
    target "SearchHospitalTests"
    target "SearchHospitalUITests"
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end

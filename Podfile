# Uncomment the next line to define a global platform for your project
platform :ios, '17.6'

target 'cafm' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for cafm
  pod 'Alamofire'
  pod 'ObjectMapper'
  pod 'SCLAlertView'
  pod 'Highcharts', '~> 11.4.6'
  pod 'FSCalendar'
  pod 'SpreadsheetView'
  pod 'SkeletonView'
  pod 'IQKeyboardManager'
  pod 'SearchTextField'
  pod 'SVGKit'
  pod 'SDWebImage'
  pod 'ImageScrollView'
end

post_install do |installer|
  ([installer.pods_project] + (installer.respond_to?(:generated_projects) ? installer.generated_projects : [])).compact.uniq.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.6'
      end
    end
  end
end

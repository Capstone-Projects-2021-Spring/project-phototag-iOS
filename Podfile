platform :ios, '12.0'
use_frameworks!

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
     end
   end
 end

target 'PhotoTag' do
  pod 'GoogleMLKit/ImageLabeling'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'Firebase/FirestoreSwift'
  pod 'FirebaseUI'
  pod 'Firebase/Analytics'
  pod 'Firebase/Database'
end

Pod::Spec.new do |s|
  s.name             = 'GeoFireX-Swift'
  s.version          = '1.0.0'
  s.summary          = 'The framework ported from GeoFireX for Swift.'
  s.description      = <<-DESC
                        This framework helps you to get geometry data from Firebase with geohash. Basic logic is the same as GeoFireX by codediodeio. (https://github.com/codediodeio/geofirex)
                       DESC

  s.homepage         = 'https://github.com/nob3rise/geofirex-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Nob"
  s.social_media_url   = "https://twitter.com/noby111"
  s.source           = { :git => 'https://github.com/nob3rise/geofirex-swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.source_files = 'GeoFireX-Swift/Classes/**/*'
  s.swift_versions = ['4.0', '4.1', '4.2', '5.0']

  s.static_framework = true
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Firestore'
  s.dependency 'FirebaseFirestoreSwift'
end

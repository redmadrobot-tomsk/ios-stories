Pod::Spec.new do |s|

	s.platform = :ios
	s.ios.deployment_target = '11.0'
	s.name = "Stories"
	s.summary = "Instagram-like stories for iOS"
	s.requires_arc = true

	s.version = "1.0.1"

	s.license = { :type => 'MIT', :text => <<-LICENSE
	   /* Copyright (C) KODE */
	    LICENSE
	  }

	s.author = { "KODE" => "iosdev@kode-t.ru" }

	s.homepage = "https://github.com/kode-t/ios-stories"

	s.source = { :git => "https://github.com/kode-t/ios-stories.git",  :branch => "master", 
	             :tag => s.version.to_s }

	s.ios.deployment_target = '13.0'

	s.framework = "UIKit"
	s.dependency 'SnapKit'
	s.dependency 'Kingfisher'

	s.source_files  = ["Sources/**/*.swift"]

	s.swift_version = "5.5"

end
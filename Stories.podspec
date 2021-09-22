Pod::Spec.new do |s|

	# 1
	s.platform = :ios
	s.ios.deployment_target = '11.0'
	s.name = "Stories"
	s.summary = "Instagram-like stories for iOS"
	s.requires_arc = true

	# 2
	s.version = "1.0.0"

	# 3
	s.license = { :type => 'MIT', :text => <<-LICENSE
	   /* Copyright (C) KODE */
	    LICENSE
	  }

	# 4 
	s.author = { "KODE" => "iosdev@kode-t.ru" }

	# 5
	s.homepage = "https://github.com/kode-t/ios-stories"

	# 6
	s.source = { :git => "git@github.com:kode-t/ios-stories.git",  :branch => "master", 
	             :tag => s.version.to_s }

	# 7
	s.framework = "UIKit"
	s.dependency 'SnapKit'
	s.dependency 'Kingfisher'

	# 8
	s.source_files = '**/Sources/**/*.{swift}'

	# 9
	s.resources = "Sources/**/*.{xcassets,strings,pdf}"

	# 10
	s.swift_version = "5.0"

end
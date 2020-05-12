
Pod::Spec.new do |s|
  s.name         = 'JLConsoleLog'
  s.version      = '1.0.2'
  s.authors      = {'jacklandrin' => 'jacklandrin@hotmail.com'}
  s.homepage     = 'http://www.jacklandrin.com'
  s.summary      = 'A convenient In-App floating log console with Swift for iOS'
  s.license      = 'MIT'
  s.source = { 
    :git => 'https://github.com/jacklandrin/JLConsoleLog',
    :tag => s.version
  }
  s.frameworks   = 'Foundation', 'UIKit'
  s.ios.deployment_target = '10.0'
  
	s.prefix_header_file = 'JLConsoleLog/JLConsoleLog/JLConsoleLog.h'
	s.source_files = ["JLConsoleLog/**/*.{h,swift}"]
  s.requires_arc = true
  s.swift_version = '5.0'

end


Pod::Spec.new do |s|
  s.name         = 'JLConsoleLog'
  s.version      = '1.0.0'
  s.authors      = {'jacklandrin' => 'jacklandrin@hotmail.com'}
  s.homepage     = 'http://www.jacklandrin.com'
  s.summary      = 'console log'
  s.source = { 
    :git => 'https://github.com/jacklandrin/JLConsoleLog',
    :tag => 'v'+s.version.to_s
  }
  s.frameworks   = 'Foundation', 'UIKit'
  s.ios.deployment_target = '9.0'
  
	s.prefix_header_file = 'JLConsoleLog/JLConsoleLog.h'
	s.source_files = ["JLConsoleLog/**/*.{h,swift}"]
  s.requires_arc = true

end

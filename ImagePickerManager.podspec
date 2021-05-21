Pod::Spec.new do |spec|

  spec.name         = "ImagePickerManager"
  spec.version      = "1.0.0"
  spec.summary      = "ImagePickerManager"

  spec.homepage     = "https://github.com/knottx/ImagePickerManager"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "Visarut Tippun" => "knotto.vt@gmail.com" }
  spec.source       = { :git => "https://github.com/knottx/ImagePickerManager.git", :tag => "#{spec.version}" }
  
  spec.swift_version   = "5.1"
  spec.ios.deployment_target = "10.0"
  spec.source_files  = "ImagePickerManager/**/*.swift"
  spec.requires_arc  = true
  
end

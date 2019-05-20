Pod::Spec.new do |spec|
  spec.name = "DCFramework"
  spec.version = "1.0.2"
  spec.summary = "常用封装。"
  spec.description = "自己封装的平常要用的类、延展以及和微信一样的图片裁剪器。"
  spec.homepage = "https://github.com/dotryTan/DCFramework"
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.authors = { 'DCFramwork' => '942659593@qq.com' }
  spec.platform = :ios, "9.0"
  spec.source = { :git => "https://github.com/dotryTan/DCFramework.git", :tag => spec.version }
  spec.source_files = "DCFramework/DCFramework/**/*.swift"
  spec.resources = "DCFramework/DCFramework/DCEditImageController/Source/*.{png,jpeg}"
  spec.framework  = "UIKit"
  spec.dependency "SnapKit"
  spec.dependency "RxCocoa"
  spec.dependency "NSObject+Rx"
  spec.swift_version = '5.0'
end

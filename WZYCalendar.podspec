Pod::Spec.new do |s|

  s.name         = "WZYCalendar"
  s.version      = "1.0.0"
  s.summary      = "WZYCalendar is a lightweight calendar controls for iOS."
  s.description  = <<-DESC
WZYCalendar is a lightweight calendar control that can be quickly integrated into the project for use. Less memory consumption, strong customization.
                   DESC
  s.homepage     = "https://github.com/CoderZYWang/WZYCalendar"
  s.license      = "MIT"
  s.author             = { "CoderZYWang" => "294250051@qq.com" }
  s.social_media_url   = "http://blog.csdn.net/felicity294250051"
  s.platform     = :ios
  s.source       = { :git => "https://github.com/CoderZYWang/WZYCalendar.git", :tag => "1.0.0" }
  s.source_files  = "WZYCalendar/*.{h,m}"
  s.frameworks = 'UIKit', 'Foundation'
  s.requires_arc = true

end

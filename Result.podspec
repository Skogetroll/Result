Pod::Spec.new do |s|

  s.name         = "Result"
  s.version      = "1.2.8"
  s.summary      = "Simple Apple Swift result type"

  s.homepage     = "https://github.com/Skogetroll/Result"


  s.license      = "MIT"

  s.author       = { "Mikhail Stepkin" => "skogetroll@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/Skogetroll/Result.git", :tag => "1.2.8" }

  s.source_files = "Sources", "Sources/**/*.{h, m, swift}"

  s.requires_arc = true

end

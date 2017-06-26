
Pod::Spec.new do |s|


  s.name         = "JSONModelWithMirror"
  s.version      = "0.0.4"
  s.summary      = "user mirror to cover a object to a son string"
  s.homepage     = "https://github.com/martinLilili/JSONModelWithMirror"
  s.author             = { "martin" => "liyue5232+li@gmail.com" }
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.source       = { :git => "https://github.com/martinLilili/JSONModelWithMirror.git", :tag => s.version }

  s.ios.deployment_target = '8.0'

  s.source_files  = "JSONModel/JSONModel.swift"
  
  s.requires_arc = true

end

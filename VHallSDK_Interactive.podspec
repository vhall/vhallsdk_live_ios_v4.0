Pod::Spec.new do |s|
  s.name            = "VHallSDK_Interactive"
  s.version         = "4.3.0"
  s.author          = { "vhall" => "xiaoxiang.wang@vhall.com" }
  s.license         = { :type => "MIT", :file => "LICENSE" }
  s.homepage        = 'https://www.vhall.com'
  s.source          = { :git => "https://github.com/vhall/vhallsdk_live_ios_v4.0.git", :tag => s.version.to_s}
  s.summary         = "VHallSDK Interactive for IOS"
  s.platform        = :ios, '9.0'
  s.requires_arc    = true
  #s.source_files   = ''
  s.libraries 	    = 'xml2.2'
  s.frameworks      = "AVFoundation", "VideoToolbox","OpenAL","CoreMedia","CoreTelephony" ,"OpenGLES" ,"MediaPlayer" ,"AssetsLibrary","QuartzCore" ,"JavaScriptCore","Security"
  s.module_name     = 'VHallSDK_Interactive'
  s.resources       = ['README.md']
  #s.resource_bundles= {}
  s.vendored_frameworks = 'VHallSDK/VHLiveSDK.framework','VHallSDK/VhallLiveBaseApi.framework','VHallSDK/VHallInteractive/WebRTC.framework','VHallSDK/VHallInteractive/VHInteractive.framework'
  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/**',
    'HEADER_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/**'
  }

end

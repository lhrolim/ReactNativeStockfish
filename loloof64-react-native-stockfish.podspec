require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'

Pod::Spec.new do |s|
  s.name         = "loloof64-react-native-stockfish"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => min_ios_version_supported }
  s.source       = { :git => "https://github.com/loloof64/loloof64-react-native-stockfish.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}", "cpp/**/*.{hpp,cpp,c,h}"

  # Use install_modules_dependencies helper to install the dependencies if React Native version >=0.71.0.
  # See https://github.com/facebook/react-native/blob/febf6b7f33fdb4904669f99d795eba4c0f95d7bf/scripts/cocoapods/new_architecture.rb#L79.
  if respond_to?(:install_modules_dependencies, true)
    install_modules_dependencies(s)
  else
    s.dependency "React-Core"

    # Don't install the dependencies when we run `pod install` in the old architecture.
    if ENV['RCT_NEW_ARCH_ENABLED'] == '1' then
      s.compiler_flags = folly_compiler_flags + " -DRCT_NEW_ARCH_ENABLED=1"
      s.pod_target_xcconfig    = {
          "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\"",
          "OTHER_CPLUSPLUSFLAGS" => "-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1",
          "CLANG_CXX_LANGUAGE_STANDARD" => "c++17"
      }
      s.dependency "React-Codegen"
      s.dependency "RCT-Folly"
      s.dependency "RCTRequired"
      s.dependency "RCTTypeSafety"
      s.dependency "ReactCommon/turbomodule/core"
    end
  end

  s.post_install do |installer|
    require 'open-uri'

    NNUE_NAME_BIG  = "nn-1111cefa1111.nnue"
    NNUE_NAME_SMALL = "nn-37f18f62d772.nnue"

    puts "Downloading big NNUE file"
    URI.open("https://tests.stockfishchess.org/api/nn/#{NNUE_NAME_BIG}") do |remote_nnue|
      File.open("cpp/#{NNUE_NAME_BIG}", "wb") do |local_nnue|
        local_nnue.write(remote_nnue.read)
      end
    end


    puts "Downloading small NNUE file"
    URI.open("https://tests.stockfishchess.org/api/nn/#{NNUE_NAME_SMALL}") do |remote_nnue|
      File.open("cpp/#{NNUE_NAME_SMALL}", "wb") do |local_nnue|
        local_nnue.write(remote_nnue.read)
      end
    end
    
  end
end

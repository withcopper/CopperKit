#
# Be sure to run `pod lib lint CopperKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'CopperKit'
s.version          = '2.1.2'
s.summary          = 'Password-free signup for your product.'

s.description      = <<-DESC
Copper is a service for developers to offer password-free authentication and signups to users. CopperKit users international SMS messages, and a beautiful, user-friendly signup form to get people into your app as quickly as possible. Copper remember users' information across apps so that they never have repeat themselves resulting in higher conversions into real users. Check signin and signup off the launch list and ship faster with Copper.
DESC

s.homepage         = 'https://github.com/withcopper/CopperKit'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Copper Technologies' => 'humans@withcopper.com' }
s.source           = { :git => 'https://github.com/withcopper/CopperKit.git', :tag => s.version.to_s }
s.social_media_url = 'https://twitter.com/withcopper'

s.ios.deployment_target = '8.2'

s.source_files = 'CopperKit/**/*.{swift,m,h,mm,hpp,cpp,c}'

s.resource_bundles = {
  'CopperKit' => ['CopperKit/**/*.{storyboard,xib,xcassets,framework}']
}

# s.public_header_files = 'CopperKit/**/*.{h}'
s.public_header_files = 'CopperKit.framework/Headers/*.h'
s.frameworks = 'UIKit', 'Foundation'
# s.dependency 'AFNetworking', '~> 2.3'
end

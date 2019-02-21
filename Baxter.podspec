#
# Be sure to run `pod lib lint ${POD_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Baxter'
  s.version          = '1.4.0'
  s.summary          = 'Baxter is a iOS/macOS/tvOS/watchOS framework that extends the CoreData framework.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Baxter is a iOS/macOS/tvOS/watchOS framework that extends the `CoreData` framework. It provides methods to simplify fetching and importing.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/Baxter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/Baxter.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  
  s.requires_arc = true

  s.source_files = 'Baxter/**/*.{h,m}'
  s.exclude_files = 'Baxter/Baxter-Info.h'
  s.osx.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}'
  s.tvos.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}'
  s.watchos.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}'
  s.private_header_files = 'Baxter/Private/*.h'
  
  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit'
  s.osx.frameworks = 'Foundation', 'CoreData'
  s.tvos.frameworks = 'Foundation', 'CoreData'
  s.watchos.frameworks = 'Foundation', 'CoreData'

  s.dependency 'Stanley'
end

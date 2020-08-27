Pod::Spec.new do |s|
  s.name             = 'Baxter'
  s.version          = '1.7.0'
  s.summary          = 'Baxter is a iOS/macOS/tvOS/watchOS framework that extends the CoreData framework.'
  s.description      = <<-DESC
Baxter is a iOS/macOS/tvOS/watchOS framework that extends the `CoreData` framework. It provides methods to simplify fetching and importing.
                       DESC

  s.homepage         = 'https://github.com/Kosoku/Baxter'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
  s.author           = { 'William Towe' => 'willbur1984@gmail.com' }
  s.source           = { :git => 'https://github.com/Kosoku/Baxter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'
  s.tvos.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'
  
  s.requires_arc = true

  s.source_files = 'Baxter/**/*.{h,m}'
  s.exclude_files = 'Baxter/Baxter-Info.h'
  s.osx.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}'
  s.tvos.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}', 'Baxter/KBAFetchedResultsController.{h,m}'
  s.watchos.exclude_files = 'Baxter/KBAFetchedResultsObserver.{h,m}', 'Baxter/KBAFetchedResultsController.{h,m}'
  s.private_header_files = 'Baxter/Private/*.h'
  
  s.ios.frameworks = 'Foundation', 'CoreData', 'UIKit'
  s.osx.frameworks = 'Foundation', 'CoreData'
  s.tvos.frameworks = 'Foundation', 'CoreData'
  s.watchos.frameworks = 'Foundation', 'CoreData'

  s.dependency 'Stanley'
end

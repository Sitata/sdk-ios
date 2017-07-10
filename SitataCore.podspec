#
# Be sure to run `pod lib lint SitataCore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SitataCore'
  s.version          = '1.1.1'
  s.summary          = 'An iOS library to embed Sitata services into your own mobile application.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An iOS library to embed Sitata services into your own mobile application. API access and UI elements provided.
                       DESC

  s.homepage              = 'https://github.com/sitata/sdk-ios'
  # s.screenshots         = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Adam St. John' => 'astjohn@sitata.com' }
  s.source                = { :git => 'https://github.com/sitata/sdk-ios.git', :tag => s.version.to_s }
  s.social_media_url      = 'https://twitter.com/_sitata_'

  s.ios.deployment_target = '9.0'


  public_header_files     = ['SitataCore/**/STASDKApiAlert.h',
                            'SitataCore/**/STASDKApiCountry.h',
                            'SitataCore/**/STASDKApiHealth.h',
                            'SitataCore/**/STASDKApiMisc.h',
                            'SitataCore/**/STASDKApiPlaces.h',
                            'SitataCore/**/STASDKApiTrip.h',
                            'SitataCore/**/STASDKController.h',
                            'SitataCore/**/STASDKDataController.h',
                            'SitataCore/**/STASDKGeo.h',
                            'SitataCore/**/STASDKApiPlaces.h',
                            'SitataCore/**/STASDKMAddress.h',
                            'SitataCore/**/STASDKMAdvisory.h',
                            'SitataCore/**/STASDKMAlert.h',
                            'SitataCore/**/STASDKMAlertLocation.h',
                            'SitataCore/**/STASDKMAlertSource.h',
                            'SitataCore/**/STASDKMContactDetail.h',
                            'SitataCore/**/STASDKMCountry.h',
                            'SitataCore/**/STASDKMDestination.h',
                            'SitataCore/**/STASDKMDestinationLocation.h',
                            'SitataCore/**/STASDKMDisease.h',
                            'SitataCore/**/STASDKMHospital.h',
                            'SitataCore/**/STASDKMMedication.h',
                            'SitataCore/**/STASDKMTrip.h',
                            'SitataCore/**/STASDKMTripHealthComment.h',
                            'SitataCore/**/STASDKMVaccination.h',
                            'SitataCore/**/STASDKSync.h',
                            'SitataCore/**/STASDKUI.h',
                            'SitataCore/**/STASDKUIStylesheet.h']

  private_header_files    = ['SitataCore/**/STASDKApiRoutes.h',
                            'SitataCore/**/STASDKApiUtils.h',
                            'SitataCore/**/STASDKDefines.h',
                            'SitataCore/**/STASDKJobs.h',
                            'SitataCore/**/STASDKLocationHandler.h',
                            'SitataCore/**/STASDKUIAlertPin.h',
                            'SitataCore/**/STASDKUIAlertsTableViewController.h',
                            'SitataCore/**/STASDKUIAlertTableViewCell.h',
                            'SitataCore/**/STASDKUIAlertViewController.h',
                            'SitataCore/**/STASDKUIContactDetailTableViewCell.h',
                            'SitataCore/**/STASDKUICopyLabel.h',
                            'SitataCore/**/STASDKUICountryPickerPopoverViewController.h',
                            'SitataCore/**/STASDKUICountrySwitcherViewController.h',
                            'SitataCore/**/STASDKUIDiseaseDetailViewController.h',
                            'SitataCore/**/STASDKUIEmergNumbersViewController.h',
                            'SitataCore/**/STASDKUIHealthCommentTableViewCell.h',
                            'SitataCore/**/STASDKUIHealthObjViewController.h',
                            'SitataCore/**/STASDKUIHealthTableViewController.h',
                            'SitataCore/**/STASDKUIHospitalClusterView.h',
                            'SitataCore/**/STASDKUIHospitalDetailViewController.h',
                            'SitataCore/**/STASDKUIHospitalExtrasTableViewCell.h',
                            'SitataCore/**/STASDKUIHospitalPin.h',
                            'SitataCore/**/STASDKUIHospitalRowTableViewCell.h',
                            'SitataCore/**/STASDKUIHospitalsPageViewController.h',
                            'SitataCore/**/STASDKUIHospitalsTableViewController.h',
                            'SitataCore/**/STASDKUIHospitalsViewController.h',
                            'SitataCore/**/STASDKUINullStateHandler.h',
                            'SitataCore/**/STASDKUISafetyDetailsViewController.h',
                            'SitataCore/**/STASDKUISafetyPageViewController.h',
                            'SitataCore/**/STASDKUISafetyViewController.h',
                            'SitataCore/**/STASDKUIUtility.h',
                            'SitataCore/**/STASDKUITripBuilderPageViewController.h',
                            'SitataCore/**/STASDKPushHandler.h',
                            'SitataCore/**/STASDKUIModalLoadingWindow.h',
                            'SitataCore/**/STASDKReachability.h',
                            'SitataCore/**/STASDKUITripBuildItinViewController.h',
                            'SitataCore/**/STASDKUITripBuilderBaseViewController.h',
                            'SitataCore/**/STASDKUITBDestPickerPageViewController.h',
                            'SitataCore/**/STASDKUITBDatePickerViewController.h','
                            'SitataCore/**/STASDKUIItineraryCountryHeaderView.h',
                            'SitataCore/**/STASDKUIItineraryCityHeaderView.h',
                            'SitataCore/**/STASDKUILocationSearchTableViewController.h',
                            'SitataCore/**/STASDKUICardTableViewCell.h']

  s.source_files          = 'SitataCore/**/*.{m,h}'

  s.public_header_files   = public_header_files
  s.private_header_files  = private_header_files
  s.requires_arc          = true
  
  s.resource_bundles = {
    'SitataCore' => ['SitataCore/Assets/**/*']
  }


  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit', 'MapKit', 'SystemConfiguration'

  s.dependency 'Realm', '~>2.6'
  s.dependency 'AFNetworking', '~> 3.1'
  s.dependency 'YYModel', '1.0.4'
  s.dependency 'EDQueue', '0.7.1'
  s.dependency 'CCHMapClusterController', '1.7.0'
  s.dependency 'Haneke', '~> 1.0'


end

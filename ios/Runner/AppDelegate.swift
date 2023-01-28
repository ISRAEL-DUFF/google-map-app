import UIKit
import Flutter
import GoogleMaps  // Import Google maps


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Google Maps API key
    GMSServices.provideAPIKey("AIzaSyC8bAiI8yDk5YEQS8VDzMIC-e0E5y446-s")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

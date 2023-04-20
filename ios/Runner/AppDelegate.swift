import UIKit
import Flutter
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
  
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60)) 
    WorkmanagerPlugin.registerTask(withIdentifier: "scooter")
  
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

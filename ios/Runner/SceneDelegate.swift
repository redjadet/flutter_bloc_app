import Flutter
import UIKit
import app_links

/// SceneDelegate responsible for managing the app's scene lifecycle.
/// This delegate handles deep links and universal links by intercepting URLs
/// from various entry points such as URL contexts and user activities.
/// It ensures links are processed once, preventing duplicate handling.
///
/// This file is scene-based and works in tandem with AppDelegate to manage lifecycle events
/// and link handling across different app states.
class SceneDelegate: FlutterSceneDelegate {
  /// Called when the scene is connecting. Processes initial URLs and user activities for deep linking.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    var handledURLs = Set<URL>()

    for urlContext in connectionOptions.urlContexts {
      handleLink(urlContext.url, source: "urlContexts", handledURLs: &handledURLs)
    }

    for userActivity in connectionOptions.userActivities {
      if let url = userActivity.webpageURL {
        handleLink(url, source: "userActivities", handledURLs: &handledURLs)
      }
    }

    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  /// Called when the app is opened via URL while the scene is active.
  /// Handles incoming URLContexts for deep linking.
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    var handledURLs = Set<URL>()

    for urlContext in URLContexts {
      handleLink(urlContext.url, source: "openURLContexts", handledURLs: &handledURLs)
    }

    super.scene(scene, openURLContexts: URLContexts)
  }

  /// Called when continuing a user activity, such as a universal link.
  /// Processes the user activity's webpageURL if available.
  override func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) {
    if let url = userActivity.webpageURL {
      var handledURLs = Set<URL>()
      handleLink(url, source: "continue userActivity", handledURLs: &handledURLs)
    }

    super.scene(scene, continue: userActivity)
  }

  private func handleLink(_ url: URL, source: String, handledURLs: inout Set<URL>) {
    guard handledURLs.insert(url).inserted else {
      debugPrint("SceneDelegate: Skipping duplicate URL from \(source): \(url.absoluteString)")
      return
    }

    if !AppLinks.shared.handleLink(url: url) {
      debugPrint("SceneDelegate: Failed to handle link from \(source): \(url.absoluteString)")
    }
  }
}

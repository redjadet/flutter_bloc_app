import Flutter
import UIKit
import app_links

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // Handle initial deep link from scene connection (replaces launchOptions handling)
    if !connectionOptions.urlContexts.isEmpty {
      for urlContext in connectionOptions.urlContexts {
        AppLinks.shared.handleLink(url: urlContext.url)
      }
    }

    // Handle initial user activity (universal links)
    if !connectionOptions.userActivities.isEmpty {
      for userActivity in connectionOptions.userActivities {
        if let url = userActivity.webpageURL {
          AppLinks.shared.handleLink(url: url)
        }
      }
    }

    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }

  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    // Handle deep links when app is opened via URL
    for urlContext in URLContexts {
      AppLinks.shared.handleLink(url: urlContext.url)
    }

    super.scene(scene, openURLContexts: URLContexts)
  }

  override func scene(
    _ scene: UIScene,
    continue userActivity: NSUserActivity
  ) {
    // Handle universal links
    if let url = userActivity.webpageURL {
      AppLinks.shared.handleLink(url: url)
    }

    super.scene(scene, continue: userActivity)
  }
}

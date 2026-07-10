import Flutter
import UIKit

final class NativeShowcaseBannerPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeShowcaseBannerPlatformView(frame: frame)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}

final class NativeShowcaseBannerPlatformView: NSObject, FlutterPlatformView {
  private let bannerView: UIView

  init(frame: CGRect) {
    let container = UIView(frame: frame)
    container.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.12)
    container.layer.cornerRadius = 8
    container.clipsToBounds = true
    container.isAccessibilityElement = true
    container.accessibilityLabel = "Native iOS platform view banner"

    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Native UIKit banner"
    label.textAlignment = .center
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.textColor = UIColor.label
    label.numberOfLines = 1
    container.addSubview(label)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
      label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
      label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
      container.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
    ])

    bannerView = container
    super.init()
  }

  func view() -> UIView {
    bannerView
  }
}

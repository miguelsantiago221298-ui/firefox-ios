// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Common
import UIKit

public class SetDefaultBrowserViewController: UIViewController,
                                              Themeable {
    public var themeManager: any Common.ThemeManager
    public var themeListenerCancellable: Any?
    public var currentWindowUUID: Common.WindowUUID?
    private var notificationCenter: NotificationProtocol
    private let child: UIViewController

    private lazy var closeButton: UIButton = .build {
        $0.setImage(
            UIImage(named: StandardImageIdentifiers.Large.cross)?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        $0.addAction(UIAction(handler: { [weak self] _ in
            self?.dismiss(animated: true)
        }), for: .touchUpInside)
        $0.showsLargeContentViewer = true
    }

    init(
        child: UIViewController,
        windowUUID: WindowUUID,
        notificationCenter: NotificationProtocol,
        themeManager: ThemeManager
    ) {
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        self.currentWindowUUID = windowUUID
        self.child = child
        super.init(nibName: nil, bundle: nil)
    }
    
    public static func factory(
        child: UIViewController,
        windowUUID: WindowUUID,
        notificationCenter: NotificationProtocol = NotificationCenter.default,
        themeManager: ThemeManager = AppContainer.shared.resolve()
    ) -> UIViewController {
        let controller = SetDefaultBrowserViewController(child: child,
                                                         windowUUID: windowUUID,
                                                         notificationCenter: notificationCenter,
                                                         themeManager: themeManager)
        let navController = UINavigationController(rootViewController: controller)
        return navController
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        listenForThemeChanges(withNotificationCenter: notificationCenter)
        applyTheme()
    }

    private func setupLayout() {
        addChild(child)
        
        view.addSubviews(child.view)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        child.view.pinToSuperview()
        child.didMove(toParent: self)
    }

    // MARK: - Themeable

    public func applyTheme() {
        let theme = themeManager.getCurrentTheme(for: currentWindowUUID)
        closeButton.tintColor = theme.colors.iconPrimary
    }
}

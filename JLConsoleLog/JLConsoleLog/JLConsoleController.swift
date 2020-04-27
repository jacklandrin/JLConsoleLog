//
//  JLConsoleController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

let ConsoleHasDismissedNotification = NSNotification.Name(rawValue:"ConsoleHasDismissedNotification")

enum ConsolePresentationStyle:Int {
    case Hidden = 0
    case FullScreen
    case Floating
}

class JLConsoleController: NSObject, OptionalViewDelegate {
    
    // MARK: - shared instance
    static let shared = JLConsoleController()
    
    // MARK: - public property
    public var style: ConsolePresentationStyle = .Hidden
    {
        didSet {
            switch style {
            case .Floating:
                self.floatingViewController.presentInWindow(window: self.floatingWindow, animated: true)
            case .FullScreen:
                self.fullScreenViewController.presentInWindow(window: self.floatingWindow, animated: true)
            case .Hidden:
                self.floatingWindow?.isHidden = true
            }
        }
    }
    
    public internal(set) var logManager = JLConsoleLogManager()
    
    public var logEnabled: Bool = false
    {
        didSet {
            self.logManager.logEnable = logEnabled
        }
    }
    
    public var followingAction: ((JLLogOptions) -> Void)?
    
    public internal(set) var allCategories:[JLConsoleLogCategory] = [JLConsoleLogCategory]()
    
    
    private let alertWindow: UIWindow? = {
        let win:UIWindow
        if #available(iOS 13, *) {
            let windowScene = UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first
            if let windowScene = windowScene as? UIWindowScene {
                win = UIWindow(windowScene: windowScene)
            } else {
                return nil
            }
            
        } else {
            win = UIWindow(frame: UIScreen.main.bounds)
        }
        win.windowLevel = UIWindow.Level.alert + 1
        return win
    }()
    
    // MARK: - private property
    lazy private var floatingWindow:UIWindow? = {
        let floatingWindow:ConsoleWindow?
        
        
        let originalKeyWindow: UIWindow = self.originalKeyWindow
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first
            if let windowScene = windowScene as? UIWindowScene {
                floatingWindow = ConsoleWindow(windowScene: windowScene)
            } else {
                return nil
            }
            
        } else {
            floatingWindow = ConsoleWindow(frame: UIScreen.main.bounds)
        }
        floatingWindow?.makeKeyAndVisible()
        originalKeyWindow.makeKey()
        floatingWindow?.backgroundColor = UIColor.clear
        floatingWindow?.windowLevel = .statusBar - 1
        
        return floatingWindow
    }()
    
    lazy private var originalKeyWindow:UIWindow = {
        let window:UIWindow
        if #available(iOS 13, *) {
            window = UIApplication.shared.windows[0]
        } else {
            window = UIApplication.shared.keyWindow!
        }
        return window
    }()
    
    lazy private var fullScreenViewController:JLConsoleViewController = {
        let vc = JLConsoleViewController()
        vc.optionalView.delegate = self
        return vc
    }()
    
    lazy private var floatingViewController:JLConsoleFloatingViewController = {
        let vc = JLConsoleFloatingViewController()
        vc.optionalView.delegate = self
        return vc
    }()
    
    public func register(newCategory:JLConsoleLogCategory) {
        self.allCategories.append(newCategory)
    }
    
   // MARK: - delegate
    func clickSettingButton(optionalView: JLConsoleOptionalView) {
        let alertController = UIAlertController(title: "setting", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: {_ in
            self.alertWindow?.isHidden = true
        })
        let categoryFilterAction = UIAlertAction(title: "category filter", style: .default, handler: { _ in
            self.showFilterViewController(type: .Category)
            self.alertWindow?.isHidden = true
        })
        
        let levelFilterAction = UIAlertAction(title: "level filter", style: .default, handler: { _ in
            self.showFilterViewController(type: .Level)
            self.alertWindow?.isHidden = true
        })
        
        let cleanAllLogAction = UIAlertAction(title: "clean all logs", style: .default, handler: { _ in
            self.logManager.clearAllLogs()
            self.alertWindow?.isHidden = true
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(categoryFilterAction)
        alertController.addAction(levelFilterAction)
        alertController.addAction(cleanAllLogAction)
        
//        if self.style == .Floating {
//            self.floatingViewController.present(alertController, animated: true, completion: nil)
//        } else if self.style == .FullScreen {
//            self.fullScreenViewController.present(alertController, animated: true, completion: nil)
//        }
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        self.alertWindow?.rootViewController = vc
        self.alertWindow?.makeKeyAndVisible()
        vc.present(alertController, animated: true, completion: nil)
        self.floatingWindow?.makeKeyAndVisible()
        self.originalKeyWindow.makeKey()
    }
    
    func shouldEnterFullScreen(optionalView: JLConsoleOptionalView) -> Bool {
        self.floatingViewController.dismiss(animated: true, completion: nil)
        self.fullScreenViewController.presentInWindow(window: self.floatingWindow, animated: true)
        self.style = .FullScreen
        return true
    }
    
    func shouldExitFullScreen(optionalView: JLConsoleOptionalView) -> Bool {
        self.fullScreenViewController.dismiss(animated: true, completion: nil)
        self.floatingViewController.presentInWindow(window: self.floatingWindow, animated: true)
        self.style = .Floating
        return true
    }
    
    func clickCloseButton(optionalView: JLConsoleOptionalView) {
        if optionalView == self.floatingViewController.optionalView {
            self.floatingViewController.dismiss(animated: true, completion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.style = .Hidden
            })
        } else if(optionalView == self.fullScreenViewController.optionalView) {
            self.fullScreenViewController.dismiss(animated: true, completion: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.style = .Hidden
            })
        }
        JLConsoleLogManager.consoleLogNotificationCenter.post(name: ConsoleHasDismissedNotification, object: nil)
        
    }
    // MARK: - private function
    private func showFilterViewController(type:FilterType) {
        let filterViewController = JLConsoleFilterViewController(style: .plain, filterType: type)
        let nvc = UINavigationController(rootViewController: filterViewController)
        if self.style == .Floating {
            self.floatingViewController.present(nvc, animated: true, completion: nil)
        } else if self.style == .FullScreen {
            self.fullScreenViewController.present(nvc, animated: true, completion: nil)
        }
    }
}

class ConsoleWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = UIViewController()
        self.rootViewController?.view.isHidden = true
    }
    
    @available(iOS 13, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.rootViewController = UIViewController()
        self.rootViewController?.view.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let superView = super.hitTest(point, with: event)
        guard superView != self else {
            return nil
        }
        
        NotificationCenter.default.post(name: ConsoleViewDidTouchNotification, object: nil)
        return superView
    }
}

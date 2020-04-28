//
//  JLConsoleViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

private let optionalViewHeight: CGFloat = 100

class JLConsoleViewController: UIViewController {
    // MARK: - private property
    private var presented:Bool = false
    
    // MARK: - public property
    lazy public var optionalView:JLConsoleOptionalView = {
        let optionalView = JLConsoleOptionalView(frame: .zero)
        
        return optionalView
    }()
    
    lazy public var canvasView: JLConsoleCanvasView = {
        let canvasView = JLConsoleCanvasView(frame: .zero)
       
        return canvasView
    }()
    
    // MARK: - override function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
        self.optionalView.isFullScreen = true
        self.canvasView.isShowSearchBar = true
        self.view.addSubview(optionalView)
        self.view.addSubview(canvasView)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewRect = self.view.frame
        optionalView.frame = CGRect(x: 0, y: 0, width: viewRect.width, height: optionalViewHeight)
        canvasView.frame = CGRect(x: 0, y: optionalViewHeight, width: viewRect.width, height: viewRect.height - optionalViewHeight)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        presented = false
        let dismissCompletion :(Bool) -> Void = { [weak self] finished in
            guard let strongSelf = self else { return }
            strongSelf.view.removeFromSuperview()
            guard let completion = completion  else {
                return
            }
            completion()
        }
        
        
        if flag{
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options:  UIView.AnimationOptions(rawValue: 0), animations: {
                let viewRect = self.view.frame
                self.view.frame = CGRect(x: viewRect.origin.x, y: -viewRect.height, width: viewRect.width, height: viewRect.height)
                self.view.layer.shadowRadius = 0.0
            }, completion: dismissCompletion)
        } else {
            dismissCompletion(true)
        }
    }
    
    // MARK: - public function
    public func presentInWindow(window: UIWindow?, animated:Bool) {
       
        guard let consoleWindow = window else {
            return
        }
        consoleWindow.isHidden = false
        
        guard self.view.superview == nil else {
            return
        }
        
        presented = true
        
        consoleWindow.addSubview(self.view)
        
        if animated {
            let windowRect = consoleWindow.frame
            self.view.frame = CGRect(x: 0, y: windowRect.height, width: windowRect.width, height: windowRect.height)
            
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.view.frame = consoleWindow.bounds
            }, completion: nil)
        } else {
            self.view.frame = consoleWindow.bounds
        }
    }
     
}

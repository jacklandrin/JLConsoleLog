//
//  JLConsoleFloatingViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/27.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

private let optionalViewHeight: CGFloat = 50
let ConsoleViewDidTouchNotification = NSNotification.Name(rawValue:"ConsoleViewDidTouchNotification")

class JLConsoleFloatingViewController: JLConsoleViewController {
    // MARK: - property
    private var draggingStartOriginY:CGFloat = 0.0
    
    private var hideTimer:Timer?
    private var presented:Bool = false
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        let gesture = UIPanNavigationGestureRecognizer(target: self, action: #selector(optionViewPanGesture(panGesture:)))
        self.optionalView.addGestureRecognizer(gesture)
        self.optionalView.isFullScreen = false
        self.canvasView.isShowSearchBar = false
        NotificationCenter.default.addObserver(forName: ConsoleViewDidTouchNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.hideTimer != nil {
                strongSelf.hideTimer?.invalidate()
            }
            
            strongSelf.hideTimer = Timer.scheduledTimer(timeInterval: 5, target: strongSelf, selector: #selector(strongSelf.autoHideViewTimer(timer:)), userInfo: nil, repeats: false)
            
            if self?.view.alpha != 1 {
                UIView.animate(withDuration: 0.5, animations: {
                    strongSelf.view.alpha = 1
                })
            }
        })
    }
    
    deinit {
        hideTimer?.invalidate()
        hideTimer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: optionalViewHeight, width: self.view.frame.width, height: 250)
        
        self.optionalView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: optionalViewHeight)
        self.canvasView.frame = CGRect(x: 0, y: optionalViewHeight, width: self.view.frame.width, height: self.view.frame.height - optionalViewHeight)
    }
    
    override func presentInWindow(window: UIWindow?, animated: Bool) {
        guard let consoleWindow = window else {
            return
        }
        
        consoleWindow.isHidden = false
        
        guard self.view.superview == nil else {
            return
        }
        
        presented = true
        
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: 64, width: consoleWindow.frame.width, height: 250)
        self.view.layer.shadowPath = UIBezierPath(rect: self.view.bounds).cgPath
        self.view.layer.shadowColor = UIColor(white: 0.2, alpha: 0.4).cgColor
        self.view.layer.shadowRadius = 30
        self.view.alpha = 1
        
       
        consoleWindow.addSubview(self.view)
        
        self.hideTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(autoHideViewTimer(timer:)), userInfo: nil, repeats: false)
        
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presented = false
        hideTimer?.invalidate()
        let dismissComplete: (Bool) -> Void = { finished in
            self.view.removeFromSuperview()
            guard let block = completion else {
                return
            }
            block()
        }
        
        if flag {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: -self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
            }, completion: dismissComplete)
        } else {
            dismissComplete(true)
        }
    }
    // MARK: - selector
    @objc func optionViewPanGesture(panGesture:UIPanNavigationGestureRecognizer) {
        let state = panGesture.state
       
        switch state {
        case .began:
            draggingStartOriginY = self.view.frame.origin.y
        case .changed:
            let translation = panGesture.translationView(view: self.view.window)
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: round(draggingStartOriginY + translation.y), width: self.view.frame.width, height: self.view.frame.height)
            self.view.layoutSubviews()
        case .ended, .failed, .cancelled:
            updateViewFrameToConstrainedAreaIfNeeded()
        default:
            break
        }
        
        draggingStartOriginY = self.view.frame.origin.y
    }
    
    @objc func autoHideViewTimer(timer:Timer) {
        timer.invalidate()
        UIView.animate(withDuration: 0.5, animations: {
            self.view.alpha = 0.5
        })
    }
    // MARK: - private function
    private func updateViewFrameToConstrainedAreaIfNeeded() {
        var targetY = self.view.frame.origin.y
        if self.view.frame.origin.y < 64 {
            targetY = 64
        } else if self.view.frame.origin.y > UIScreen.main.bounds.height - self.view.frame.height {
            targetY = UIScreen.main.bounds.height - self.view.frame.height
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: targetY, width: self.view.frame.width, height: self.view.frame.height)
        })
    }
}

class UIPanNavigationGestureRecognizer: UIGestureRecognizer {
    // MARK: - property
    private var touch:UITouch?
    private var startPoint:CGPoint = .zero
    private var currentPoint:CGPoint = .zero
    private var lastUpdateTime:TimeInterval = 0
    // MARK: - public function
    public func translationView(view:UIView?) -> CGPoint {
        guard let _ = view else {
            return .zero
        }
        
        guard let currentView = self.view else {
            return .zero
        }
        let start = currentView.convert(startPoint, to: view)
        let now = currentView.convert(currentPoint, to: view)
        return CGPoint(x: now.x - start.x, y: now.y - start.y)
    }
    // MARK: - private function
    private func setTouch(aTouch:UITouch?) {
        if touch != aTouch {
            touch = aTouch
        }
    }
    // MARK: - override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        

        
        startPoint = .zero
        currentPoint = .zero
        
        let aTouch = touches.first
        guard let touch = aTouch else {
            return
        }
        setTouch(aTouch: touch)
        startPoint = touch.location(in: self.view)
        currentPoint = startPoint
        self.state = .possible
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let aTouch = touch, touches.contains(aTouch) else {
            return
        }
        
        currentPoint = aTouch.location(in: self.view)
        if self.state == .possible {
            let x = currentPoint.x - startPoint.y
            let y = abs(currentPoint.y - startPoint.y)
            if x > 8 && x / y > 2 {
                self.state = .began
                return
            }
        }
        
        if self.state == .began || self.state == .changed {
            self.state = .changed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        guard let aTouch = touch, touches.contains(aTouch) else {
            return
        }
        setTouch(aTouch: nil)
        switch self.state {
        case .began, .changed:
            self.state = .recognized
        case .possible:
            self.state = .failed
        default:
            break
        }
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        
        guard let aTouch = touch, touches.contains(aTouch) else {
            return
        }
        setTouch(aTouch: nil)
        switch self.state {
        case .began, .changed:
            self.state = .recognized
        case .possible:
            self.state = .cancelled
        default:
            break
        }
    }
    
}

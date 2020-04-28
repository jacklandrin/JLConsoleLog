//
//  JLBubbleViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/28.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

protocol BubbleViewControllerDelegate {
    func dismissBubble(bubble:JLBubbleViewController)
}

enum BubbleOnEdge: Int {
    case left = 0, top, right, bottom
}

let BubbleEdge:CGFloat = 64

class JLBubbleViewController: UIViewController, JLConsoleViewControllerProvider {

    // MARK: - property
    private var draggingStartOriginY:CGFloat = 0.0
    private var draggingStartOriginX:CGFloat = 0.0
    private var presented:Bool = false
    private var bubbleOnEdge:BubbleOnEdge = .left
    
    public var delegate:BubbleViewControllerDelegate?
    
    lazy public var warningLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 0, width: 60, height: 30))
        label.text = "⚠ 0"
        label.textColor = .yellow
        label.textAlignment = .center
        return label
    }()
    
    lazy public var errorLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 34, width: 60, height: 30))
        label.text = "☠︎ 0"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    lazy public var invisableButton:UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: BubbleEdge, height: BubbleEdge))
        button.addTarget(self, action: #selector(dismissBubble(button:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
        self.view.addSubview(warningLabel)
        self.view.addSubview(errorLabel)
        self.view.addSubview(invisableButton)
        
        let gesture = UIPanBubbleGestureRecognizer(target: self, action: #selector(panGesture(panGesture:)))
        self.view.addGestureRecognizer(gesture)
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: WarningCountChangeNotification, object: nil, queue: .main, using: { _ in
            self.warningLabel.text = "⚠ \(JLConsoleController.shared.logManager.warningCount)"
        })
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: ErrorCountChangeNotification, object: nil, queue: .main, using: { _ in
            self.errorLabel.text = "☠︎ \(JLConsoleController.shared.logManager.errorCount)"
        })
    }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        presented = false
       
        let dismissComplete: (Bool) -> Void = { finished in
            self.view.removeFromSuperview()
            guard let block = completion else {
                return
            }
            block()
        }
        
        if flag {
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
                switch self.bubbleOnEdge {
                case .left:
                    self.view.frame = CGRect(x: -BubbleEdge, y: self.view.frame.origin.y, width: BubbleEdge, height: BubbleEdge)
                case .right:
                    self.view.frame = CGRect(x: UIScreen.main.bounds.width + BubbleEdge, y: self.view.frame.origin.y, width: BubbleEdge, height: BubbleEdge)
                case .top:
                    self.view.frame = CGRect(x: self.view.frame.origin.x, y: -BubbleEdge, width: BubbleEdge, height: BubbleEdge)
                case .bottom:
                    self.view.frame = CGRect(x: self.view.frame.origin.x, y: UIScreen.main.bounds.height + BubbleEdge, width: BubbleEdge, height: BubbleEdge)
                }
                
            }, completion: dismissComplete)
        } else {
            dismissComplete(true)
        }
    }
    
    func presentInWindow(window: UIWindow?, animated: Bool) {
        guard let consoleWindow = window else {
            return
        }
       
        consoleWindow.isHidden = false
       
        guard self.view.superview == nil else {
            return
        }
       
        presented = true
        
        self.view.frame = CGRect(x: 0, y: 100, width: BubbleEdge, height: BubbleEdge)
        self.view.layer.shadowPath = UIBezierPath(rect: self.view.bounds).cgPath
        self.view.layer.shadowColor = UIColor(white: 0.2, alpha: 0.4).cgColor
        self.view.layer.shadowRadius = 30
        self.view.layer.masksToBounds = true
        self.view.layer.cornerRadius = 10
        self.view.alpha = 0.5
        consoleWindow.addSubview(self.view)
    }

    
    // MARK: - private function
    private func updateViewFrameToConstrainedAreaIfNeeded() {
        let radius = BubbleEdge / 2
        let centerX = self.view.frame.origin.x + radius
        let centerY = self.view.frame.origin.y + radius
        
        let margin = [centerX, centerY, UIScreen.main.bounds.width - centerX, UIScreen.main.bounds.height - centerY]
        self.bubbleOnEdge = BubbleOnEdge(rawValue: margin.indices.min(by: {margin[$0] < margin[$1]}) ?? 0)!
        
        UIView.animate(withDuration: 0.2, animations: {
            switch self.bubbleOnEdge {
            case .left:
                self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y, width: BubbleEdge, height: BubbleEdge)
            case .right:
                self.view.frame = CGRect(x: UIScreen.main.bounds.width - BubbleEdge, y: self.view.frame.origin.y, width: BubbleEdge, height: BubbleEdge)
            case .top:
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: 0, width: BubbleEdge, height: BubbleEdge)
            case .bottom:
                self.view.frame = CGRect(x: self.view.frame.origin.x, y: UIScreen.main.bounds.height - BubbleEdge, width: BubbleEdge, height: BubbleEdge)
            }
            
        })
    }
    
    // MARK: - selector
    @objc func panGesture(panGesture:UIPanBubbleGestureRecognizer) {
        let state = panGesture.state
           
            switch state {
            case .began:
                draggingStartOriginY = self.view.frame.origin.y
                draggingStartOriginX = self.view.frame.origin.x
            case .changed:
                let translation = panGesture.translationView(view: self.view.window)
                self.view.frame = CGRect(x: round(draggingStartOriginX + translation.x), y: round(draggingStartOriginY + translation.y), width: self.view.frame.width, height: self.view.frame.height)
                self.view.layoutSubviews()
            case .ended, .failed, .cancelled:
                updateViewFrameToConstrainedAreaIfNeeded()
            default:
                break
            }
            
            draggingStartOriginY = self.view.frame.origin.y
            draggingStartOriginX = self.view.frame.origin.x
    }
    
    @objc func dismissBubble(button:UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.dismissBubble(bubble: self)
    }
}


class UIPanBubbleGestureRecognizer: UIGestureRecognizer {
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
            if x > 5 && x / y > 2 {
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

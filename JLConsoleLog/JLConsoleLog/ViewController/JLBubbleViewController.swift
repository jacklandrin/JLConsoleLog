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

var BubbleEdge:CGFloat {
    JLConsoleController.shared.performanceMonitable ? 134 : 64
}

class JLBubbleViewController: UIViewController, JLConsoleViewControllerProvider {

    // MARK: - property
    private var draggingStartOriginY:CGFloat = 0.0
    private var draggingStartOriginX:CGFloat = 0.0
    private var presented:Bool = false
    private var bubbleOnEdge:BubbleOnEdge = .left
    
    public var delegate:BubbleViewControllerDelegate?
    
    lazy public var warningLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 0, width: 60, height: 28))
        label.text = "⚠ 0"
        label.textColor = .yellow
        label.textAlignment = .center
        return label
    }()
    
    lazy public var errorLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 32, width: 60, height: 28))
        label.text = "☠︎ 0"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    lazy public var cpuLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 64, width: 100, height: 30))
        label.text = "cpu: 0"
        label.textColor = .green
        label.textAlignment = .center
        return label
    }()
    
    lazy public var memoryLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 2, y: 96, width: 130, height: 30))
        label.text = "memory: 0MB"
        label.textColor = .green
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
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
        self.view.addSubview(cpuLabel)
        self.view.addSubview(memoryLabel)
        self.view.addSubview(invisableButton)
        
        let gesture = JLPanNavigationGestureRecognizer(target: self, action: #selector(panGesture(panGesture:)))
        self.view.addGestureRecognizer(gesture)
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: WarningCountChangeNotification, object: nil, queue: .main, using: { _ in
            self.warningLabel.text = "⚠ \(JLConsoleController.shared.logManager.warningCount)"
        })
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: ErrorCountChangeNotification, object: nil, queue: .main, using: { _ in
            self.errorLabel.text = "☠︎ \(JLConsoleController.shared.logManager.errorCount)"
        })
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: PerformanceMonitorNotification, object: nil, queue: .main, using: { [weak self] notification in
            guard let strongSelf = self else { return }
            let currentPerformance:[PerformanceMonitor.monitorType:String] = notification.object as! [PerformanceMonitor.monitorType : String]
            let cpuText:String! = currentPerformance[.cpu] ?? "0"
            strongSelf.cpuLabel.text = "cpu: " + String(cpuText)  + "%"
            let cpuDouble:Double = (cpuText as NSString).doubleValue
            if cpuDouble > 80 {
                strongSelf.cpuLabel.textColor = .red
            } else {
                strongSelf.cpuLabel.textColor = .green
            }
            
            let memoryText:String! = currentPerformance[.memory] ?? "0"
            strongSelf.memoryLabel.text = "memory: " + String(memoryText) + "MB"
            
        })
        
        cpuLabel.isHidden = !JLConsoleController.shared.performanceMonitable
        memoryLabel.isHidden = !JLConsoleController.shared.performanceMonitable
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
    
    func changeShownItems() {
        cpuLabel.isHidden = !JLConsoleController.shared.performanceMonitable
        memoryLabel.isHidden = !JLConsoleController.shared.performanceMonitable
        self.view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: BubbleEdge, height: BubbleEdge)
        invisableButton.frame = CGRect(x: 0, y: 0, width: BubbleEdge, height: BubbleEdge)
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
    @objc func panGesture(panGesture:JLPanNavigationGestureRecognizer) {
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


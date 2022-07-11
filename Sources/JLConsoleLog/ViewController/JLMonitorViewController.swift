//
//  JLMonitorViewController.swift
//  JLConsoleLog
//
//  Created by jack on 2020/5/7.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

let MonitorHeight:CGFloat = 250.0
let BarHeight:CGFloat = 50.0

protocol MonitorViewControllerDelegate {
    func dismissMonitor(bubble:JLMonitorViewController)
}

class JLMonitorViewController: UIViewController,JLConsoleViewControllerProvider {

    public var delegate:MonitorViewControllerDelegate?
    
    var monitorType:PerformanceMonitor.monitorType = .cpu
    {
        willSet {
            if monitorType != newValue {
                cardiogram.reset()
            }
        }
        
        didSet {
            switch monitorType {
            case .cpu:
                cardiogram.yAxisUnit = "cpu %"
                cardiogram.maxValue = 100.0
                titleLabel.text = "CPU Monitor"
            case .memory:
                cardiogram.yAxisUnit = "memory MB"
                titleLabel.text = "Memory Monitor"
            case .fps:
                cardiogram.yAxisUnit = "fps"
                cardiogram.maxValue = 140.0
                titleLabel.text = "FPS Monitor"
            }
        }
    }
    private var draggingStartOriginY:CGFloat = 0.0
    
    lazy private var titleLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: (self.view.frame.width - 200) / 2, y: 10, width: 200, height: 30))
        label.textColor = .yellow
        label.textAlignment = .center
        return label
    }()
    
    lazy private var closeButton:UIButton = {
        let closeButton = UIButton(frame: CGRect(x: self.view.frame.width - 40, y: 10, width: 30, height: 30))
        closeButton.backgroundColor = UIColor.purple
        closeButton.setTitle("☒", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClick(button:)), for: .touchUpInside)
        return closeButton
    }()
    
    lazy private var barView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: BarHeight))
        view.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
        return view
    }()
    
   lazy  private var cardiogram:CardiogramView = {
        let cardiogram = CardiogramView(frame: CGRect(x: 0, y: BarHeight, width: self.view.frame.width, height: self.view.frame.height - BarHeight))
        cardiogram.backgroundColor = .yellow
        cardiogram.xAxisUnit = "time s"
        return cardiogram
   }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(barView)
        barView.addSubview(closeButton)
        barView.addSubview(titleLabel)
        let gesture = JLPanNavigationGestureRecognizer(target: self, action: #selector(panGesture(panGesture:)))
        barView.addGestureRecognizer(gesture)
        
        self.view.addSubview(cardiogram)
        
        JLConsoleLogManager.consoleLogNotificationCenter.addObserver(forName: PerformanceMonitorNotification, object: nil, queue: .main, using: { [weak self] notification in
            guard let strongSelf = self else { return }
            let currentPerformance:[PerformanceMonitor.monitorType:String] = notification.object as! [PerformanceMonitor.monitorType : String]
            
            switch strongSelf.monitorType {
                case .cpu:
                    let cpuText:String! = currentPerformance[.cpu] ?? "0"
                    let cpuDouble:Double = (cpuText as NSString).doubleValue
                    strongSelf.cardiogram.update(newPoint: cpuDouble)
                case .memory:
                    let memoryText:String! = currentPerformance[.memory] ?? "0"
                    let memoryDouble:Double = (memoryText as NSString).doubleValue
                    strongSelf.cardiogram.update(newPoint: memoryDouble)
                case .fps:
                    let fpsText:String! = currentPerformance[.fps] ?? "0"
                    let fpsDouble:Double = (fpsText as NSString).doubleValue
                    strongSelf.cardiogram.update(newPoint: fpsDouble)
            }
            
        })
    }
    
    @objc func closeButtonClick(button:UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        delegate.dismissMonitor(bubble: self)
    }
    
    @objc func panGesture(panGesture:JLPanNavigationGestureRecognizer) {
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
    
    func presentInWindow(window: UIWindow?, animated: Bool) {
       guard let consoleWindow = window else {
            return
        }
        
        consoleWindow.isHidden = false
        
        guard self.view.superview == nil else {
            return
        }
       
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: 64, width: consoleWindow.frame.width, height: MonitorHeight)
        self.view.layer.shadowPath = UIBezierPath(rect: self.view.bounds).cgPath
        self.view.layer.shadowColor = UIColor(white: 0.2, alpha: 0.4).cgColor
        self.view.layer.shadowRadius = 30
        self.view.alpha = 0.8
        
        consoleWindow.addSubview(self.view)
   }
    
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.frame = CGRect(x: self.view.frame.origin.x, y: BarHeight, width: self.view.frame.width, height: 250)
        self.barView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: BarHeight)
        self.cardiogram.frame = CGRect(x: 0, y: BarHeight, width: self.view.frame.width, height: self.view.frame.height - BarHeight)
        self.titleLabel.frame = CGRect(x: (self.view.frame.width - 200) / 2, y: 10, width: 200, height: 30)
    }
    
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

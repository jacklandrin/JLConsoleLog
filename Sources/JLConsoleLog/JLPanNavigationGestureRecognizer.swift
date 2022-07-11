//
//  UIPanGesture.swift
//  JLConsoleLog
//
//  Created by jack on 2020/5/7.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit
class JLPanNavigationGestureRecognizer: UIGestureRecognizer {
    // MARK: - property
    private var touch:UITouch?
    private var startPoint:CGPoint = .zero
    private var currentPoint:CGPoint = .zero
    private var lastUpdateTime:TimeInterval = 0
    // MARK: - public function
    func translationView(view:UIView?) -> CGPoint {
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

//
//  JLConsoleOptionalView.swift
//  JLConsoleLog
//
//  Created by jack on 2020/4/26.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit

protocol OptionalViewDelegate: NSObject {
    func clickSettingButton(optionalView:JLConsoleOptionalView)
    func shouldEnterFullScreen(optionalView:JLConsoleOptionalView) -> Bool
    func shouldExitFullScreen(optionalView:JLConsoleOptionalView) -> Bool
    func clickCloseButton(optionalView:JLConsoleOptionalView)
}

class JLConsoleOptionalView: UIView {

    // MARK: - property
    
    public var isFullScreen: Bool = false
    {
        didSet {
            if isFullScreen {
                self.fullScreenButton.backgroundColor = UIColor.red
            } else {
                self.fullScreenButton.backgroundColor = UIColor.blue
            }
        }
    }
    
    public weak var delegate: OptionalViewDelegate?
    
    lazy public var settingButton: UIButton = {
        let settingButton = UIButton(frame: CGRect(x: 10, y: self.frame.height - 42, width: 30, height: 30))
        settingButton.backgroundColor = UIColor.green
        settingButton.setTitle("⚙", for: .normal)
        settingButton.addTarget(self, action: #selector(settingButtonClick(button:)), for: .touchUpInside)
        return settingButton
    }()
    
    lazy public var fullScreenButton:UIButton = {
        let fullScreenButton = UIButton(frame: CGRect(x: 50, y: self.frame.height - 42, width: 30, height: 30))
        fullScreenButton.backgroundColor = UIColor.blue
        fullScreenButton.setTitle("🂠", for: .normal)
        fullScreenButton.addTarget(self, action: #selector(fullScreenButtonClick(button:)), for: .touchUpInside)
        return fullScreenButton
    }()
    
    lazy public var closeButton:UIButton = {
        let closeButton = UIButton(frame: CGRect(x: self.frame.width - 40, y: self.frame.height - 42, width: 30, height: 30))
        closeButton.backgroundColor = UIColor.purple
        closeButton.setTitle("☒", for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonClick(button:)), for: .touchUpInside)
        return closeButton
    }()
    
    
    // MARK: - selector
    @objc func settingButtonClick(button: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.clickSettingButton(optionalView: self)
    }
    
    @objc func fullScreenButtonClick(button: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        
        if isFullScreen {
            if delegate.shouldExitFullScreen(optionalView: self) {
                button.backgroundColor = UIColor.red
                button.setTitle("🁙", for: .normal)
            }
        } else {
            if delegate.shouldEnterFullScreen(optionalView: self) {
                button.backgroundColor = UIColor.blue
                button.setTitle("🂠", for: .normal)
            }
        }
    }
    
    @objc func closeButtonClick(button: UIButton) {
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.clickCloseButton(optionalView: self)
    }
    
    // MARK: - function
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.settingButton)
        self.addSubview(self.fullScreenButton)
        self.addSubview(self.closeButton)
        self.backgroundColor = UIColor.init(white: 0.5, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.settingButton.frame = CGRect(x: self.settingButton.frame.origin.x, y: self.frame.height - 42, width: self.settingButton.frame.width, height: self.settingButton.frame.height)
        self.fullScreenButton.frame = CGRect(x: self.fullScreenButton.frame.origin.x, y: self.frame.height - 42, width: self.fullScreenButton.frame.width, height: self.fullScreenButton.frame.height)
        self.closeButton.frame = CGRect(x: self.frame.width - 40, y: self.frame.height - 42, width: self.closeButton.frame.width, height: self.closeButton.frame.height)
    }
}

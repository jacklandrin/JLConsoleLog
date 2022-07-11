//
//  CardiogramView.swift
//  JLCardiogram
//
//  Created by jack on 2020/5/7.
//  Copyright © 2020 jack. All rights reserved.
//

import UIKit


class CardiogramView: UIView {
    // MARK: - constance
    let labelHeight:CGFloat = 15
    let labelWidth:CGFloat = 100
    // MARK: - struct
    struct CardiogramPoint {
        var value: Double
        var location: CGPoint
        var label:UILabel = UILabel()
        func setLabel() {
            label.text = String(format: "%.1f", value)
            label.font = UIFont.systemFont(ofSize: 10)
            label.frame = CGRect(origin: location, size: CGSize(width: 40, height: 15))
        }
    }
    // MARK: - public properties
    public var lineColor: UIColor = .black {
        didSet {
            self.lineShape.strokeColor = lineColor.cgColor
        }
    }
    public var gridLineColor: UIColor = .lightGray
    {
        didSet {
            self.gridShape.strokeColor = gridLineColor.cgColor
        }
    }
    
    public var lableColor: UIColor = .black
    {
        didSet {
            self.xLabel.textColor = lableColor
            self.yLabel.textColor = lableColor
        }
    }
    public var pointColor: UIColor = .brown
    {
        didSet {
            self.pointShape.strokeColor = pointColor.cgColor
        }
    }
    public var unitLength: CGFloat = 30.0
    public var xAxisUnit: String = "s"
    {
        didSet{
            self.xLabel.text = xAxisUnit
        }
    }
    public var yAxisUnit: String = ""
    {
        didSet{
            self.yLabel.text = yAxisUnit
        }
    }
    
    public var maxValue:Double = 0.0
    {
        didSet {
            self.currentMaxValue = maxValue
            self.maxValueLabel.text = String(format: "%.1f", maxValue)
        }
    }
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - public function
    public func update(newPoint:Double) {
        let multiple = points.count < pointsMaxCount ? points.count : points.count - 1
        let x = labelHeight + CGFloat(multiple) * unitLength
        let y = CGFloat(1 - newPoint / currentMaxValue) * (self.frame.height - labelHeight - remainder) + remainder
        let cardiogramPoint = CardiogramPoint(value: newPoint, location: CGPoint(x: x, y: y))
        
        if isDynamicMaxValue {
            let tempArray = points + [cardiogramPoint]
            let maxPoint = tempArray.max(by: {$0.value < $1.value})
            currentMaxValue = maxPoint!.value
        }
        
        points = points.map{ point in
            point.label.removeFromSuperview()
            let newY = CGFloat(1 - point.value / currentMaxValue) * (self.frame.height - labelHeight - remainder) + remainder
            let np = CardiogramPoint(value: point.value, location: CGPoint(x: point.location.x - (points.count == pointsMaxCount ? unitLength : 0), y: newY))
            np.label.textColor = self.pointColor
            self.addSubview(np.label)
            np.setLabel()
            return np
        }
        
        if points.count == pointsMaxCount {
            points[0].label.removeFromSuperview()
            points.remove(at: 0)
        }
        
        cardiogramPoint.label.textColor = self.pointColor
        points.append(cardiogramPoint)
        self.addSubview(cardiogramPoint.label)
        
        cardiogramPoint.setLabel()
        drawPoints()
        
        
    }
    
    public func reset() {
        for point in points {
            point.label.removeFromSuperview()
        }
        points.removeAll()
        maxValue = 0.0
    }
    
    // MARK: - private properties
    private var pointsMaxCount:Int {
        Int((self.frame.width - labelHeight) / unitLength)
    }
    
    private var points: [CardiogramPoint] = [CardiogramPoint]()
    
    private var currentMaxValue:Double = 0.0 {
        didSet {
            self.maxValueLabel.text = String(format: "%.1f", currentMaxValue)
        }
    }
    
    private var isDynamicMaxValue:Bool {
        self.maxValue == 0.0
    }
    
    private var remainder:CGFloat {
        return (self.frame.height - labelHeight).truncatingRemainder(dividingBy: unitLength)
    }
    
    lazy private var gridShape:CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = self.gridLineColor.cgColor
        return shape
    }()
    
    lazy private var lineShape:CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = self.lineColor.cgColor
        return shape
    }()
    
    lazy private var pointShape:CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = self.pointColor.cgColor
        return shape
    }()
    
    lazy private var yLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = self.lableColor
        label.text = self.yAxisUnit
        label.textAlignment = .right
        label.center = CGPoint(x: labelHeight / 2, y: labelWidth / 2)
        let transform = label.transform.rotated(by: CGFloat(-90 * CGFloat.pi / 180.0))
        label.transform = transform
        return label
    }()
    
    lazy private var xLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: self.frame.width - labelWidth, y: self.frame.height - labelHeight, width: labelWidth, height: labelHeight))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = self.lableColor
        label.text = self.xAxisUnit
        label.textAlignment = .right
        return label
    }()
    
    lazy private var maxValueLabel:UILabel = {
        let label = UILabel(frame: CGRect(x: labelHeight, y: remainder, width: labelWidth, height: labelHeight))
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = self.pointColor
        label.text = String(self.currentMaxValue)
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - private functions
    private func setView() {
        self.addSubview(yLabel)
        self.addSubview(xLabel)
        self.layer.addSublayer(gridShape)
        self.layer.addSublayer(lineShape)
        self.layer.addSublayer(pointShape)
        self.addSubview(maxValueLabel)
        makeLines()
    }
    
    private func makeLines() {
        let path = UIBezierPath()
        //make horizontal lines
        var currentY = self.frame.height - labelHeight
        while currentY > 0 {
            path.move(to: CGPoint(x: labelHeight, y: currentY))
            path.addLine(to: CGPoint(x: self.frame.width, y: currentY))
            currentY -= unitLength
        }
        
        //make vertical lines
        var currentX = labelHeight
        while currentX < self.frame.width {
            path.move(to: CGPoint(x: currentX, y: self.frame.height - labelHeight))
            path.addLine(to: CGPoint(x: currentX, y: 0.0))
            currentX += unitLength
        }
        
        gridShape.path = path.cgPath
        
    }
    
    private func drawPoints() {
       let pointPath = UIBezierPath()
       let linePath = UIBezierPath()
       linePath.move(to: points[0].location)
       for point in points {
           let circlePath = UIBezierPath(arcCenter: point.location, radius: 2, startAngle: CGFloat(0), endAngle:CGFloat(CGFloat.pi * 2), clockwise: true)
           pointPath.append(circlePath)
           linePath.addLine(to: point.location)
           linePath.move(to: point.location)
       }
       
       self.pointShape.path = pointPath.cgPath
       self.lineShape.path = linePath.cgPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeLines()
        xLabel.frame = CGRect(x: self.frame.width - labelWidth, y: self.frame.height - labelHeight, width: labelWidth, height: labelHeight)
//        yLabel.frame = CGRect(x: 0, y: 0, width: labelWidth, height: labelHeight)
        maxValueLabel.frame = CGRect(x: labelHeight, y: remainder, width: labelWidth, height: labelHeight)
    }
}

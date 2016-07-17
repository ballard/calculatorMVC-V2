//
//  GraphView.swift
//  CalculatorMVC
//
//  Created by Ivan on 13.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    let Axes = AxesDrawer()
    var chartData = [value]()
    
    @IBInspectable
    var scale : CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var graphOriginPointX : CGFloat {
        get {
            return pointAxesCenter.x
        }
        set {
            pointAxesCenter.x = newValue
        }
    }
    
    @IBInspectable
    var graphOriginPointY: CGFloat {
        get {
            return pointAxesCenter.y
        }
        set {
            pointAxesCenter.y = newValue
        }
    }
    
    var pointAxesCenter = CGPoint(x: 0.0, y: 0.0) { didSet {setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        Axes.drawAxesInRect(self.bounds, origin: pointAxesCenter, pointsPerUnit: scale)
        drawMultiLine()
//        drawLine(value(x: 10.0, y: 10.0), pointEnd: value(x: 30.0, y: 30.0))
    }
    
    func drawLine(pointStart : value, pointEnd : value) {
        let path = UIBezierPath()
        path.moveToPoint(pointFromValue(chartData[0]))
        path.addLineToPoint(pointFromValue(chartData[1]))
        path.lineWidth = 3.0
        path.stroke()
    }
    
    func drawMultiLine(){
        if chartData.count > 0{
            let path = UIBezierPath()
            path.moveToPoint(pointFromValue(chartData[0]))
            for valueIndex in 1..<chartData.count {
                path.addLineToPoint(pointFromValue(chartData[valueIndex]))
            }
            path.lineWidth = 3.0
            path.stroke()
        }
    }
    
    func pointFromValue ( pointValue : value ) -> CGPoint {
        return CGPoint(x: pointAxesCenter.x + (pointValue.x * scale), y: pointAxesCenter.y - (pointValue.y * scale))
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
}

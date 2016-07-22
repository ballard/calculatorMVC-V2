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
    
    private let Axes = AxesDrawer()
    
    var graphFunc : ((CGFloat) -> CGFloat)? = nil { didSet { setNeedsDisplay() } }
    
    var xGraphPoint  : CGFloat = 0.0
    
    var xValue : CGFloat { get { return (xGraphPoint - pointAxesCenter.x) / scale } }
    
    @IBInspectable
    var scale : CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var pointAxesCenterStored : CGPoint?  { didSet {setNeedsDisplay() } }
    
    var pointAxesCenter : CGPoint{
        get{
            return pointAxesCenterStored ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set{
            pointAxesCenterStored = newValue
        }
    }
    
    override func drawRect(rect: CGRect) {
        Axes.drawAxesInRect(self.bounds, origin: pointAxesCenter, pointsPerUnit: scale)
        let path = UIBezierPath()
        path.lineWidth = 3.0
        UIColor.blueColor().setStroke()
        var yGraphPoint : CGFloat = 0.0
        var isFirstValue = false
        for valueIndex in 0..<Int(bounds.maxX * contentScaleFactor){
            xGraphPoint = CGFloat(valueIndex) / contentScaleFactor
            if let yValue = graphFunc?(xValue) where yValue.isNormal || yValue.isZero {
                yGraphPoint = (pointAxesCenter.y - (yValue * scale))
                if isFirstValue{
                    path.addLineToPoint(CGPoint(x: xGraphPoint, y: yGraphPoint ))
                } else {
                    path.moveToPoint(CGPoint(x: xGraphPoint, y: yGraphPoint ))
                    isFirstValue = true
                }
            }
        }
        path.stroke()
    }    
}

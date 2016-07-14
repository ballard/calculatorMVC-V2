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
    
    @IBInspectable
    var scale : CGFloat = 5.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var point = CGPoint(x: 0.0, y: 0.0) { didSet {setNeedsDisplay()} }
    
    override func drawRect(rect: CGRect) {
        Axes.drawAxesInRect(self.bounds, origin: point, pointsPerUnit: scale)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

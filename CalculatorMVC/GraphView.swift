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
    
    override func drawRect(rect: CGRect) {
        Axes.drawAxesInRect(self.bounds, origin: self.center, pointsPerUnit: CGFloat(10))
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

//
//  GraphPopOverViewController.swift
//  CalculatorMVC
//
//  Created by Ivan Lazarev on 20.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class GraphPopOverViewController: UIViewController {
    
    
    @IBOutlet weak var scaleLabel: UILabel!{
        didSet{
            scaleLabel.text! += String(scale)
        }
    }
    @IBOutlet weak var yMaxLabel: UILabel!{
        didSet{
            yMaxLabel.text! += String(yMax)
        }
    }
    @IBOutlet weak var yMinLabel: UILabel!{
        didSet{
            yMinLabel.text! += String(yMin)
        }
    }
    @IBOutlet weak var xMaxLabel: UILabel!{
        didSet{
            xMaxLabel.text! += String(xMax)
        }
    }
    @IBOutlet weak var xMinLabel: UILabel!{
        didSet{
            xMinLabel.text! += String(xMin)
        }
    }
    
    var xMin : CGFloat = 0.0, xMax : CGFloat = 0.0, yMin : CGFloat = 0.0, yMax : CGFloat = 0.0, scale : CGFloat = 0.0

    @IBAction func closingTap(recoznizer: UITapGestureRecognizer) {
        if recoznizer.state == .Ended{
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

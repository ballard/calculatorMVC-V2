//
//  GraphViewController.swift
//  CalculatorMVC
//
//  Created by Ivan Lazarev on 12.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    
    
    @IBOutlet weak var graphView: GraphView!
    
    
    @IBOutlet weak var graphLabel: UILabel!{
        didSet{
            graphLabel.text = graphLabelValue
        }
    }    
    
    var graphLabelValue = "Default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.title = "Default"

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

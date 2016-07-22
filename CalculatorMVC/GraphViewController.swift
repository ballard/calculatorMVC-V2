//
//  GraphViewController.swift
//  CalculatorMVC
//
//  Created by Ivan Lazarev on 12.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    @IBOutlet private weak var graphView: GraphView!{
        didSet{
            graphView?.graphFunc = graphFunc
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    private var graphSettings = [AnyObject]()
    typealias PropertyList = AnyObject
    var settings : PropertyList {
        get {
            return graphSettings
        }
    }
    
    var graphFunc : ((CGFloat) -> CGFloat)?
    
    override internal func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        graphView?.pointAxesCenter =  CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
        
        if let settingsValues = defaults.objectForKey("graphCalcSettings") as? [AnyObject]{
            for settingsValue in settingsValues{
                if let scale = settingsValue as? CGFloat{
                    graphView?.scale = scale
                } else if let center = settingsValue as? NSString{
                    graphView?.pointAxesCenter = CGPointFromString(String(center))
                }
            }
        }
    }
    
    private var previousGraphScale : CGFloat = 0.0
    private var previousGraphOrigin : CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    override internal func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previousGraphScale = graphView.scale
        previousGraphOrigin = graphView.pointAxesCenter
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        graphSettings.append(graphView.scale)
        graphSettings.append(NSStringFromCGPoint(graphView.pointAxesCenter))
        defaults.setObject(settings, forKey: "graphCalcSettings")
    }
    
    @IBAction private func zoom(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            graphView?.scale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    @IBAction private func tap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended{
            graphView?.pointAxesCenter = recognizer.locationInView(graphView)
        }
    }
    
    private var previousPanCoordinates = CGPoint(x: 0.0, y: 0.0)
    
    @IBAction private func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            previousPanCoordinates = recognizer.locationInView(graphView)
        case .Changed, .Ended:
            graphView?.pointAxesCenter.x += (recognizer.locationInView(graphView).x - previousPanCoordinates.x)
            graphView?.pointAxesCenter.y += (recognizer.locationInView(graphView).y - previousPanCoordinates.y)
            previousPanCoordinates = recognizer.locationInView(graphView)
        default:
            break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let graphpopvc = segue.destinationViewController.contentViewController as? GraphPopOverViewController{
            graphpopvc.navigationItem.title = "Graph properties"
            graphpopvc.xMin = -1 * ( graphView.pointAxesCenter.x / graphView.scale)
            graphpopvc.xMax = (graphView.bounds.maxX - graphView.pointAxesCenter.x) / graphView.scale
            graphpopvc.yMin = -1 * (graphView.bounds.maxY - graphView.pointAxesCenter.x) / graphView.scale
            graphpopvc.yMax = graphView.pointAxesCenter.y / graphView.scale
            graphpopvc.scale = graphView.scale
        }
    }
}

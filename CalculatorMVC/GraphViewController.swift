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
    
    var graphFunc : ((CGFloat) -> CGFloat)? {
        didSet{
            graphView?.graphFunc = graphFunc
        }
    }
    
    private struct Keys{
        static let Scale = "GraphViewController.Scale"
        static let Center = "GraphViewController.RelativeCenter"
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    private var graphSettings = [AnyObject]()
    typealias PropertyList = AnyObject
    var settings : PropertyList {
        get {
            return graphSettings
        }
    }
    
    private var pointRelativeToCenterStored : CGPoint?
    private var pointRelativeToCenter : CGPoint{
        get{
            return pointRelativeToCenterStored ?? CGPointZero
        }
        set{
            pointRelativeToCenterStored = newValue
        }
    }
    
    override internal func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if let center = defaults.objectForKey(Keys.Center) as? String{
            let relativeCenter = CGPointFromString(center)
            graphView?.pointAxesCenter = CGPoint(x: relativeCenter.x * graphView.bounds.midX, y:relativeCenter.y * graphView.bounds.midY)
        } else {
            graphView?.pointAxesCenter =  CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
        }
        if let scale = defaults.objectForKey(Keys.Scale) as? CGFloat{
            graphView?.scale = scale
        }
    }
    
    override internal func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let gvc = graphView {
            pointRelativeToCenter = CGPoint(x: gvc.pointAxesCenter.x / gvc.bounds.midX, y: gvc.pointAxesCenter.y / gvc.bounds.midY)
        }
    }
    
    override func viewDidLayoutSubviews() {
        graphView?.pointAxesCenter = CGPoint(x: pointRelativeToCenter.x * graphView.bounds.midX, y:pointRelativeToCenter.y * graphView.bounds.midY)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        defaults.setObject(graphView.scale, forKey: Keys.Scale)
        defaults.setObject(NSStringFromCGPoint(CGPoint(x: graphView.pointAxesCenter.x / graphView.bounds.midX, y: graphView.pointAxesCenter.y / graphView.bounds.midY)), forKey: Keys.Center)
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

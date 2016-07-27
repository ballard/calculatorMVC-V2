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
        static let Center = "GraphViewController.AxesCenter"
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()

    private var pointRelativeToCenter : CGPoint{
        get{
            if let center = defaults.objectForKey(Keys.Center) as? String {
                let relativeCenter = CGPointFromString(center)
                return CGPoint(x: relativeCenter.x * graphView.bounds.midX, y: relativeCenter.y * graphView.bounds.midY)
            } else {
                return CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
            }
        }
        set{
            defaults.setObject(NSStringFromCGPoint(CGPoint(x: newValue.x / graphView.bounds.midX, y: newValue.y / graphView.bounds.midY)), forKey: Keys.Center)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        graphView?.pointAxesCenter = pointRelativeToCenter
        if let scale = defaults.objectForKey(Keys.Scale) as? CGFloat{
            graphView?.scale = scale
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        pointRelativeToCenter = graphView.pointAxesCenter
        defaults.setObject(graphView.scale, forKey: Keys.Scale)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.pointRelativeToCenter = self.graphView.pointAxesCenter
        coordinator.animateAlongsideTransition(nil) { [weak weakSelf = self] (context) in
            weakSelf?.graphView?.pointAxesCenter = (weakSelf?.pointRelativeToCenter)!
        }
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

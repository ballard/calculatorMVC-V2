//
//  GraphViewController.swift
//  CalculatorMVC
//
//  Created by Ivan Lazarev on 12.07.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

struct value {
    var x : CGFloat = 1.0
    var y : CGFloat = 1.0
}

class GraphPoint{
    var x : CGFloat = 0.0
    var y : CGFloat = 0.0
}

class GraphViewController: UIViewController {
    
    @IBOutlet private weak var graphView: GraphView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    private var chartSettings = [AnyObject]()
    
    typealias PropertyList = AnyObject
    
    var settings : PropertyList {
        get {
            return chartSettings
        }
    }
    
    var chartFunc : ((CGFloat) -> CGFloat)? = nil
    
    override internal func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        graphView?.pointAxesCenter =  CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)
        printGraphData()
        
        if let settingsValues = defaults.objectForKey("graphCalcSettings") as? [AnyObject]{
            if settingsValues.count == 3{
                graphView?.scale = (settingsValues[0] as? CGFloat)!
                graphView?.pointAxesCenter.x = (settingsValues[1] as? CGFloat)!
                graphView?.pointAxesCenter.y = (settingsValues[2] as? CGFloat)!
            }
//            for settingsValue in settingsValues{
//                if let scale = settingsValue as? CGFloat{
//                    graphView?.scale = scale
//                } else if let center = settingsValue as? GraphPoint{
//                    graphView?.pointAxesCenter.x = center.x
//                    graphView?.pointAxesCenter.y = center.y
//                }
//            }
        }
        chartSettings.append(graphView.scale)
        chartSettings.append(graphView.pointAxesCenter.x)
        chartSettings.append(graphView.pointAxesCenter.y)
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
        
        if chartSettings.count == 3{
            chartSettings[0] = graphView.scale
            chartSettings[1] = graphView.pointAxesCenter.x
            chartSettings[2] = graphView.pointAxesCenter.y
        }
        
        defaults.setObject(settings, forKey: "graphCalcSettings")
    }
    
    @IBAction private func zoom(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            graphView?.scale *= recognizer.scale
            recognizer.scale = 1.0
            printGraphData ()
        default:
            break
        }
    }
    
    @IBAction private func tap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended{
            graphView.pointAxesCenter = recognizer.locationInView(graphView)
            printGraphData()
        }
    }
    
    private var previousPanCoordinates = CGPoint(x: 0.0, y: 0.0)
    
    @IBAction private func pan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            previousPanCoordinates = recognizer.locationInView(graphView)
        case .Changed, .Ended:
            graphView.graphOriginPointX += (recognizer.locationInView(graphView).x - previousPanCoordinates.x)
            graphView.graphOriginPointY += (recognizer.locationInView(graphView).y - previousPanCoordinates.y)
            previousPanCoordinates = recognizer.locationInView(graphView)
            printGraphData()
        default:
            break
        }
    }

    private func printGraphData() {
        if let function = chartFunc {
            let chartPoints = graphView.bounds.maxX
            let xMin = -1 * ( graphView.graphOriginPointX / graphView.scale)
            let xMax = (chartPoints - graphView.graphOriginPointX) / graphView.scale
            let xDelta = xMax - xMin
            let xStep = xDelta/CGFloat(chartPoints)
            var graphData = [value]()
            for graphIndex in 1...Int(chartPoints){
                let xValue = xMin + (xStep * CGFloat(graphIndex))
                let yValue = function(xValue)
                if yValue.isNormal || yValue.isZero {
                    graphData.append(value(x: xValue, y: yValue))
                }
            }
            graphView.chartData = graphData
            print("X min  : \( xMin )")
            print("X max  : \( xMax )")
            print("Y max : \(graphView.graphOriginPointY / graphView.scale)")
            print("Y min  : \( -1 * (graphView.bounds.maxY - graphView.graphOriginPointY) / graphView.scale))")
            print("X points : \(graphView.bounds.maxX * graphView.scale)")
            print("Graph scale: \(graphView.scale)")
        }
    }
}

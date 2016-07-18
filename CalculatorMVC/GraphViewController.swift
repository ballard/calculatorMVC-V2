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

class GraphViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!
    
    var chartFunc : ((CGFloat) -> CGFloat)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        graphView?.pointAxesCenter =  CGPoint(x: graphView.bounds.midX, y: graphView.bounds.midY)//graphView.center
        printGraphData()
    }
    
    var previousGraphScale : CGFloat = 0.0
    var previousGraphOrigin : CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    override func viewWillLayoutSubviews() {
        previousGraphScale = graphView.scale
        previousGraphOrigin = graphView.pointAxesCenter
    }
    
    override func viewDidLayoutSubviews() {
        graphView?.scale = previousGraphScale
        graphView?.pointAxesCenter = graphView.pointAxesCenter
    }
    
    @IBAction func zoom(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed,.Ended:
            graphView?.scale *= recognizer.scale
            recognizer.scale = 1.0
            printGraphData ()
        default:
            break
        }
    }
    
    @IBAction func tap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended{
            graphView.pointAxesCenter = recognizer.locationInView(graphView)
            printGraphData()
        }
    }
    
    var previousPanCoordinates = CGPoint(x: 0.0, y: 0.0)
    
    @IBAction func pan(recognizer: UIPanGestureRecognizer) {
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

    func printGraphData() {
        if let function = chartFunc {
            let chartPoints = graphView.bounds.width
            let xMin = -1 * ( graphView.graphOriginPointX / graphView.scale)
            let xMax = (graphView.bounds.maxX - graphView.graphOriginPointX) / graphView.scale
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

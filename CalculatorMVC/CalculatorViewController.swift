//
//  ViewController.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

protocol CalculatorBrainDelegate {
    func trackPending( value: Bool)
}

class CalculatorViewController: UIViewController, UISplitViewControllerDelegate, CalculatorBrainDelegate {

    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var graphButton: UIButton!
    
    private let decimalSeparator = NSNumberFormatter().decimalSeparator
    
    private let numberStyle = NSNumberFormatter()
    
    private var userIsInTheMiddleOfTypingANumber = false
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var settings = [AnyObject]()
    
    typealias PropertyList = AnyObject
    
    private var settingsProgram : PropertyList{
        get {
            return settings
        }
    }
    
    private var isAppLoaded = false
    
    func trackPending(value: Bool) {
        if value {
            graphButton!.enabled = false
            graphButton!.setTitle("📈", forState: UIControlState.Normal)
        } else {
            graphButton!.enabled = true
            graphButton!.setTitle("📉", forState: UIControlState.Normal)
        }
    }
    
    private var brain = CalculatorBrain()
    
    private var displayValue: Double? {
        get{
            return numberStyle.numberFromString(display.text!)?.doubleValue ?? nil
        }
        set{
            let result = newValue ?? 0
            if let report = brain.errorReport {
                display.text = report
                brain.errorReport = nil
            } else {
                display.text = numberStyle.stringFromNumber(result)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberStyle.numberStyle = .DecimalStyle
        numberStyle.maximumFractionDigits = 6
        numberStyle.notANumberSymbol = "Error"
        splitViewController?.delegate = self
        brain.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !isAppLoaded{
            if let settingsValues = defaults.objectForKey("calcSettings") as? [AnyObject] where settingsValues.count > 0 {
                print("loading setup: \(settingsValues.last!)")
                brain.program = settingsValues.last!
                displayValue = brain.result
                history.text = brain.description + (brain.isPartialResult ? "..." : "=")
                performSegueWithIdentifier("graph", sender: nil)            }
        }
        isAppLoaded = true
    }
    
    @IBAction func backSpace(sender: AnyObject) {
        if userIsInTheMiddleOfTypingANumber{
            if display.text != nil {
                if display.text!.characters.count > 1 {
                    display.text!.removeAtIndex(display.text!.endIndex.predecessor())
                } else {
                    display.text = "0"
                    userIsInTheMiddleOfTypingANumber = false
                }
            }
        } else {
            brain.undo()
            displayValue = brain.result
            history.text = brain.description + (brain.isPartialResult ? "..." : "=")            
        }
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber{
                if display.text!.rangeOfString(decimalSeparator) == nil || digit != decimalSeparator {
                    display.text = display.text! + digit
                }
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction private func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            if let operand = displayValue{
                brain.setOperand(operand)
                userIsInTheMiddleOfTypingANumber = false
            }
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
        }
        displayValue = brain.result
        history.text = brain.description + (brain.isPartialResult ? "..." : "=")
    }
    
    @IBAction func setVariable() {
        if let operand = displayValue{
            brain.variableValues["M"] = operand
            displayValue = brain.result
            print("variableValues: \(brain.variableValues)")
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func getVariable(sender: UIButton) {
        if let variableValue = sender.currentTitle{
            brain.setOperand(variableValue)
            history.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
        
    @IBAction func clear() {
        brain.clear()
        brain.variableValues.removeAll()
        displayValue = nil
        history.text = " "
        userIsInTheMiddleOfTypingANumber = false
        settings = []
        defaults.removeObjectForKey("calcSettings")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let graphvc = segue.destinationViewController.contentViewController as? GraphViewController{
            graphvc.navigationItem.title = brain.description
            graphvc.graphFunc = ({ [weak weakSelf = self] (inputValue: CGFloat) -> CGFloat in
                weakSelf?.brain.variableValues["M"] = Double(inputValue)
                if let result = weakSelf?.brain.result{
                    return CGFloat(result)
                } else {
                    return 0.0
                }
            })
            settings = []
            settings.append(brain.program)
            defaults.setObject(settingsProgram, forKey: "calcSettings")
            print("settings saved: \(settings) program: \(brain.program)")
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if !brain.isPartialResult{
            return true
        } else {
            return false
        }
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        if primaryViewController.contentViewController == self{
            if secondaryViewController.contentViewController is GraphViewController{
                return true
            }
        }
        return false
    }
}


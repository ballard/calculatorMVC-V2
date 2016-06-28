//
//  ViewController.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    private var userIsInTheMiddleOfTypingANumber = false
    
    let decimalSeparator = NSNumberFormatter().decimalSeparator
    
    private var brain = CalculatorBrain()
    
    private let numberStyle = NSNumberFormatter()
    
    private var displayValue: Double? {
        get{
            if let result = numberStyle.numberFromString(display.text!)?.doubleValue {
                return result
            } else {
                return nil
            }
        }
        set{
            if let result = newValue {
                display.text = numberStyle.stringFromNumber(result)
            } else {
                display.text = "0"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberStyle.numberStyle = .DecimalStyle
        numberStyle.maximumFractionDigits = 6
        numberStyle.notANumberSymbol = "Error"
    }
    
    @IBAction func backSpace(sender: AnyObject) {
        if display.text != nil {
            if display.text!.characters.count > 1 {
                display.text!.removeAtIndex(display.text!.endIndex.predecessor())
            } else {
                display.text = "0"
                userIsInTheMiddleOfTypingANumber = false
            }
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
    
    @IBAction func clear() {
        brain.clear()
        displayValue = nil
        history.text = " "
    }
}



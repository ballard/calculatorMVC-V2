//
//  CalculatorBrain.swift
//  CalculatorMVC
//
//  Created by Ivan on 25.04.16.
//  Copyright © 2016 Ivan. All rights reserved.
//

import Foundation

class CalculatorBrain
{   
    private var accumulator = 0.0
    private var descriptionAccumulator = "0" {
        didSet{
            if pending == nil {
                currentPredecence = Int.max
            }
        }
    }
    
    private var currentPredecence = Int.max
    private var internalProgram  = [AnyObject]()
    private let numberStyle = NSNumberFormatter()

    init()
    {
        numberStyle.numberStyle = .DecimalStyle
        numberStyle.maximumFractionDigits = 6
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        descriptionAccumulator = numberStyle.stringFromNumber(operand)!
    }
    
    private var operations = [
        "I" : Operation.Random(drand48()),
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "ln" : Operation.UnaryOperation(log){"ln(" + $0 + ")" },
        "x²" : Operation.UnaryOperation({pow($0, 2)}){ "(" + $0 + ")²" },
        "1/x" : Operation.UnaryOperation({1/$0}){ "(1/(" + $0 + "))" },
        "√" : Operation.UnaryOperation(sqrt){"√(" + $0 + ")"},
        "cos" : Operation.UnaryOperation({cos(M_PI*$0/180)}){"cos(" + $0 + ")"},
        "sin" : Operation.UnaryOperation({sin(M_PI*$0/180)}){"sin(" + $0 + ")"},
        "±" : Operation.UnaryOperation({-$0}){"-(" + $0 + ")"},
        "×" : Operation.BinaryOperation(*, 1){$0 + "×" + $1},
        "÷" : Operation.BinaryOperation(/, 1){$0 + "÷" + $1},
        "+" : Operation.BinaryOperation(+, 0){$0 + "+" + $1},
        "−" : Operation.BinaryOperation(-, 0){$0 + "−" + $1},
        "=": Operation.Equals
    ]
    
    private enum Operation {
        case Random(Double)
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String)->String)
        case BinaryOperation((Double,Double) -> Double, Int, (String,String)->String)
        case Equals
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol]{
            internalProgram.append(symbol)
            switch operation {
            case.Random(let value):
                accumulator = value
                descriptionAccumulator = numberStyle.stringFromNumber(value)!
            case .Constant (let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation (let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation (let function, let predecence, let descriptionFunction):
                executePendingBinaryOperation()
                if currentPredecence < predecence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPredecence = predecence
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation(){
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: pendingBinaryOperationInfo?
    
    private struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var isPartialResult: Bool {
        return pending != nil
    }
    
    var result: Double? {
//        if accumulator.isNaN {
//            return nil
//        } else {
            return accumulator
//        }
    }
    
    var description: String{
        if pending == nil {
            return descriptionAccumulator
        } else {
            return pending!.descriptionFunction(pending!.descriptionOperand, pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
        }
    }
    
    func clear(){
        pending = nil
        accumulator = 0.0
        internalProgram.removeAll()
        descriptionAccumulator = "0"
    }
    
    typealias PropertyList = AnyObject
    
    var program : PropertyList{
        get {
            return internalProgram
        }
        set{
            self.clear()
            if let ArrayOfOps = newValue as? [AnyObject]{
                for op in ArrayOfOps{
                    if let operand = op as? Double{
                        self.setOperand(operand)
                    }
                    else if let operation = op as? String{
                        self.performOperation(operation)
                    }
                }
            }
        }
    }
}



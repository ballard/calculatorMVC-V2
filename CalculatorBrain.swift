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
    
    var errorReport:String? = nil
    
    private var descriptionAccumulator = "0" {
        didSet{
            if pending == nil {
                currentPredecence = Int.max
            }
        }
    }
    
    var variableValues = [String:Double](){
        didSet{
            program = internalProgram
        }
    }
    
    private var currentPredecence = Int.max
    private var internalProgram  = [AnyObject]()
    private let numberStyle = NSNumberFormatter()
    
    func undo() {
        if !internalProgram.isEmpty{
            internalProgram.removeLast()
            program = internalProgram
        }
        print("internal program: \(internalProgram)")
    }

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
    
    func setOperand(variableName: String) {
        operations[variableName] = Operation.Variable
        performOperation(variableName)
    }
    
    private var operations = [
        "I" : Operation.Random(drand48()),
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "ln" : Operation.UnaryOperation(log, {"ln(" + $0 + ")" }, { (s1) in return nil}),
        "x²" : Operation.UnaryOperation({pow($0, 2)},{ "(" + $0 + ")²" }, { (s1) in return nil}),
        "1/x" : Operation.UnaryOperation({1/$0},{ "(1/(" + $0 + "))" }, { (s1) in if isinf(s1) { return "zero divide" } else {return nil}}),
        "√" : Operation.UnaryOperation(sqrt, {"√(" + $0 + ")"}, {(s1) in if isnan(s1) {return "negative root"} else { return nil } }),
        "cos" : Operation.UnaryOperation(cos, {"cos(" + $0 + ")"}, { (s1) in return nil} ),
        "sin" : Operation.UnaryOperation(sin, {"sin(" + $0 + ")"}, { (s1) in return nil} ),
        "±" : Operation.UnaryOperation(-, {"-(" + $0 + ")"}, {(s1) in return nil}),
        "×" : Operation.BinaryOperation(*, 1, {$0 + "×" + $1}, {(s1) in return nil}),
        "÷" : Operation.BinaryOperation(/, 1, {$0 + "÷" + $1}, {(s1) in if isinf(s1) { return "zero divide"} else { return nil } }),
        "+" : Operation.BinaryOperation(+, 0, {$0 + "+" + $1}, {(s1) in return nil}),
        "−" : Operation.BinaryOperation(-, 0, {$0 + "−" + $1}, {(s1) in return nil}),
        "=": Operation.Equals{(s1) in if isinf(s1) { return "zero divide"} else { return nil } }
    ]
    
    private enum Operation {
        case Variable
        case Random(Double)
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String)->String, (Double)->String?)
        case BinaryOperation((Double,Double) -> Double, Int, (String,String)->String,(Double)->String?)
        case Equals((Double)->String?)
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol]{
            internalProgram.append(symbol)
            switch operation {
            case .Variable:
                accumulator = variableValues[symbol] ?? 0.0
                descriptionAccumulator = symbol
            case.Random(let value):
                accumulator = value
                descriptionAccumulator = numberStyle.stringFromNumber(value)!
            case .Constant (let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .UnaryOperation (let function, let descriptionFunction, let report):
                accumulator = function(accumulator)
                errorReport = report(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation (let function, let predecence, let descriptionFunction, let report):
                errorReport = report(executePendingBinaryOperation())
                if currentPredecence < predecence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPredecence = predecence
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals (let report):
                errorReport = report(executePendingBinaryOperation())
            }
        }
    }
    
    private func executePendingBinaryOperation() -> Double {
        if pending != nil{
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
        return accumulator
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
        return accumulator
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
//        currentVariable = ""
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
//                        currentVariable = operation
                        self.performOperation(operation)
                    }
                }
            }
        }
    }
}



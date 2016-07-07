//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Michael Chang on 6/5/16.
//  Copyright © 2016 Michael Chang. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    // for calculating
    var accumulator = 0.0
    var calculated: Double?
    
    // for saving
    private var variable = ""
    private var internalProgram = [AnyObject]()
    
    // for logging
    private var isPartialResult = false
    private var log = " "
    
    // saves operand entries
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    // stores operations
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "cos" : Operation.UnaryOperation(cos),
        "√" : Operation.UnaryOperation(sqrt),
        "±" : Operation.UnaryOperation({ -$0 }),
        "sq" : Operation.UnaryOperation({ $0 * $0 }),
        "×": Operation.BinaryOperation({ $0 * $1 }),
        "÷": Operation.BinaryOperation({ $0 / $1 }),
        "+": Operation.BinaryOperation({ $0 + $1 }),
        "−": Operation.BinaryOperation({ $0 - $1 }),
        "=": Operation.Equals
    ]
    
    // categories operations
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        
        if let constant = operations[symbol] {
            switch constant {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
                log += (" \(symbol)")
                calculated = accumulator
                
            case .UnaryOperation(let function):
                switch (isPartialResult, log.characters.count) {
                case (true, _):
                    log += (" \(symbol) (\(accumulator)) ")         // append symbol-accumulator
                case (false, 0...1):
                    log = (" \(symbol) (\(accumulator)) ")      // start with symbol-accumulator
                case (false, 2...Int.max-1):
                    log = (" \(symbol) (\(log)) ")              // symbol everything
                default:
                    fatalError()
                }
                accumulator = function(accumulator)
                calculated = accumulator
                
            case .BinaryOperation(let function):
                if isPartialResult == true {
                    if let _ = calculated {
                        log += (" \(symbol)")                       // add symbol to calculated, prepare for new op
                        calculated = nil
                    } else {
                        log += (" \(accumulator) \(symbol)")        // add new op
                    }
                } else {
                    // if log short, start from scratch : restart from equal
                    log += log.characters.count <= 1 ? (" \(accumulator) \(symbol)") : (" \(symbol)")
                }
                executePendingBinaryOperation()
                pending = pendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
                isPartialResult = true
                    
//                switch (isPartialResult, calculated, log.characters.count) {
//                case (true, let _, _): log += (" \(symbol)")                     // add symbol to calculated, prepare for new op
//                calculated = nil
//                case (true, nil, _): log += (" \(accumulator) \(symbol)")        // add new op
//                case (false, _, 0...1): log += (" \(accumulator) \(symbol)")
//                case (false, _, 2...Int.max-1): log += (" \(symbol)")
//                default: fatalError()
//                }
                
            case .Equals:                                   // write logic for making = repeat prior function executed
                if calculated != nil {
                    calculated = nil
                } else {
                    log += (" \(accumulator)")
                }
                executePendingBinaryOperation()
            }
        }
    }
    
    var pending: pendingBinaryOperationInfo?
    
    struct pendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        
        init(binaryFunction: (Double, Double) -> Double, firstOperand: Double) {
            self.binaryFunction = binaryFunction
            self.firstOperand = firstOperand
        }
    }
    
    private func executePendingBinaryOperation()
    {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            isPartialResult = false
            pending = nil
        }
    }
    
    // stores variable name
    func setOperand(variableName: String) {
        internalProgram.append(variableName)
        log += (" \(variableName)")
        variableValues[variableName] = 0.0
        accumulator = 0.0
        calculated = variableValues[variableName]
    }
    
    // stores variable values
    var variableValues: Dictionary<String, Double> = [
        :]
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        calculated = nil
        log = " "
        isPartialResult = false
        variable = ""
        internalProgram.removeAll()
    }
    
    var description: String {
        if isPartialResult {
            return log + " ..."
        } else {
            return log + " ="
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
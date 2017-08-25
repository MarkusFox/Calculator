//
//  CalculatorModel.swift
//  Calculator
//
//  Created by Markus Fox on 06.04.17.
//  Copyright © 2017 Markus Fox. All rights reserved.
//

import Foundation

//faculty crashes when you use non-natural number -> should be Int
//not sure about all the type conversions best practice, but it works *.*
func faculty(_ facultyOf: Double) -> Double {
    let typeCast = Int(facultyOf)
    if typeCast == 2 {
        return 2
    } else {
        return Double(typeCast * Int(faculty(Double(typeCast) - 1)))
    }
}

struct CalculatorModel {
    
    private var accumulator: Double?
    
    private var internalProgram = [AnyObject]()
    
    private var description: String = ""
    
    private var isPartialResult = false
    
    var M = 0.0
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    mutating func setOperand(variableName: String){
        if let variableValue = variableValues[variableName] {
            accumulator = variableValue
            internalProgram.append(variableValue as AnyObject)
        }
    }
    
    var variableValues: Dictionary<String, Double> = [
        "x" : 81.0,
        "y" : 9.0,
        "M" : 0.0
    ]
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(Double.pi),
        /*
         e wurde durch C ersetzt wegen Aufwand ^^
        "e" : Operation.Constant(M_E),
         */
        "💙" : Operation.Constant(5.3),
        "√" : Operation.UnaryOperation(sqrt),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "!" : Operation.UnaryOperation(faculty), //is a different kind of operation?! but whatever for now
        "*" : Operation.BinaryOperation({ $0 * $1 }),
        "/" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "-" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    mutating func performOperation(_ symbol: String) {
        internalProgram.append(symbol as AnyObject)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let const):
                accumulator = const
                isPartialResult = false
            case .UnaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
                isPartialResult = false
            case .BinaryOperation(let function):
                executePendingBinaryOperation()
                
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
                isPartialResult = true
            case .Equals:
                executePendingBinaryOperation()
                isPartialResult = false
            }
        }
    }
    
    private mutating func executePendingBinaryOperation(){
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        var function: (Double, Double) -> Double
        var firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func updateDescription(button: String!){
        if let operation = operations[button!] {
            switch operation {
            case .Constant( _):
                description.append(" " + button + " ")
            case .UnaryOperation( _):
                description = "\(button!)(\(description))"
            case .BinaryOperation( _):
                description.append(" " + button + " ")
            case .Equals:
                break
            }
        } else {
            description.append(button)
        }
    }
    mutating func updateDescription(number: Int!){
        if let value = number {
            if !isPartialResult {
                description = String(value)
            } else {
                description.append(String(value))
            }
            
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorModel.PropertyList
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
    
    mutating func clear() {
        accumulator = 0.0
        isPartialResult = false
        description = " "
        internalProgram.removeAll()
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    var text: String {
        get {
            return description
        }
    }
    
    var pendingPartialResult: Bool {
        get {
            return isPartialResult
        }
    }
    
    var variableM: Double {
        get {
            return M
        }
        set {
            
        }
    }
    
}

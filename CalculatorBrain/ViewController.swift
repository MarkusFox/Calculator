//
//  ViewController.swift
//  Calculator
//
//  Created by Markus Fox on 05.04.17.
//  Copyright © 2017 Markus Fox. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stringDisplay: UILabel!
    @IBOutlet private weak var display: UILabel!
    
    private var model = CalculatorModel()
    
    private var userIsInTheMiddleOfTyping = false
    private var commaIsUsed = false
    
    @IBAction private func touchNumber(_ sender: UIButton) {
        let num = sender.currentTitle
        if num == "." {
            if commaIsUsed {
                return
            }
            commaIsUsed = true
        }
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text
            display.text = textCurrentlyInDisplay! + num!
        } else {
            display.text = num
            userIsInTheMiddleOfTyping = true
        }
        model.updateDescription(number: Int(num!))
    }
    
    @IBAction func touchVariable(_ sender: UIButton) {
        let variable = sender.currentTitle
        display.text = variable
        userIsInTheMiddleOfTyping = true
        
        model.updateDescription(button: variable)
    }
    
    private var displayValue: Double {
        get {
            if let correctValue = Double(display.text!) {
                return correctValue
            } else if let variable = model.variableValues[display.text!] {
                return variable
            } else {
                return 0.0
            }
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var stringValue: String {
        get {
            return model.text
        }
        set {
            stringDisplay.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorModel.PropertyList?
    
    @IBAction func save() {
        savedProgram = model.program
    }
    @IBAction func restore() {
        if savedProgram != nil {
            model.program = savedProgram!
            displayValue = model.result!
            stringValue = model.text
        }
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            model.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
            commaIsUsed = false
        }
        
        if let symbol = sender.currentTitle {
            model.performOperation(symbol)
            model.updateDescription(button: symbol)
        }
        if let result = model.result {
            displayValue = result
        }
        
        if model.pendingPartialResult {
            stringValue = model.text + "..."
        } else {
            stringValue = model.text + " ="
        }
    }
    
    @IBAction func setM() {
        if let newM = Double(display.text!) {
            model.variableValues["M"] = newM
        }
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        model.clear()
        userIsInTheMiddleOfTyping = false
        commaIsUsed = false
        displayValue = 0.0
        stringValue = " "
    }
    
    
    
    
    
    /*      wird daweil nicht verwendet
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */


}


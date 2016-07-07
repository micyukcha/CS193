//
//  ViewController.swift
//  Calculator
//
//  Created by Michael Chang on 6/3/16.
//  Copyright © 2016 Michael Chang. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet private weak var sequence: UILabel!
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var pointCount = 0
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func createM(sender: UIButton) {
        brain.setOperand(sender.currentTitle!)
        print(brain.description, brain.accumulator, brain.variableValues, savedProgram)
    }
    
    @IBAction func saveM(sender: UIButton) {
        brain.variableValues["M"] = displayValue                    // save displayValue into dict of variables
        savedProgram = brain.program                                // cast as AnyObject
        let indexValue = savedProgram?.indexOfObject("M")           // find index of M
        
        var tempProgram = (savedProgram as! [AnyObject])            // create clone
        tempProgram[indexValue!] = displayValue                     // edit clone
        savedProgram = tempProgram                                  // replace savedProgram with updated

        print("wrapped:", savedProgram, brain.program, "ok")
        brain.program = savedProgram!
        displayValue = brain.result
    }
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func deleteDigit(sender: UIButton) {
        let textCurrentlyInDisplay = display.text!
        display.text = String(textCurrentlyInDisplay.characters.dropLast())
    }
    
    @IBAction func clearDisplay(sender: UIButton) {
        brain.clear()
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if pointCount == 0 {
                display.text = textCurrentlyInDisplay + digit
                if digit == "." {
                    pointCount += 1     //can be optimized into one line of code
                }
            } else {
                display.text = textCurrentlyInDisplay
            }
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        print(brain.description, brain.accumulator, brain.variableValues, savedProgram)
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        sequence.text = brain.description
        print(brain.description, brain.accumulator, brain.variableValues, savedProgram)
    }
}


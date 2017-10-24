//
//  ViewController.swift
//  simple-calc
//
//  Created by Xinyi Wang on 10/22/17.
//  Copyright © 2017 Xinyi Wang. All rights reserved.
//
//  Project: simple-calc
//  Class: INFO 449

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var zero: UIButton!
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var eight: UIButton!
    @IBOutlet weak var nine: UIButton!
    @IBOutlet weak var point: UIButton!
    @IBOutlet weak var negative: UIButton!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var subtract: UIButton!
    @IBOutlet weak var times: UIButton!
    @IBOutlet weak var divide: UIButton!
    @IBOutlet weak var mod: UIButton!
    @IBOutlet weak var equal: UIButton!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var fact: UIButton!
    @IBOutlet weak var count: UIButton!
    @IBOutlet weak var avg: UIButton!
    @IBOutlet weak var enter: UIButton!
    @IBOutlet weak var resultArea: UILabel!
    
    // Different types of buttons
    var buttons: Array<UIButton> = []
    var numbers: Array<UIButton> = []
    var operators: Array<UIButton> = []
    var multiOperand: Array<UIButton> = []
    
    // Data to keep track of the calculating process
    var inputNumbers: [Double] = []
    var lastInput = "0"
    var calcOperator = ""
    var resultText = ""
    var lastOperator: UIButton? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttons = [zero, one, two, three, four, five, six, seven, eight, nine, point, negative, add, subtract, times, divide, mod, equal, clear, fact, count, avg, enter]
        self.numbers = [zero, one, two, three, four, five, six, seven, eight, nine, point, negative]
        self.operators = [add, subtract, times, divide, mod]
        self.multiOperand = [fact, count, avg]

        // Change the appearance of buttons
        for element in buttons {
            element.layer.cornerRadius = 37.5
        }
        // Display the default view
        for element in multiOperand {
            element.isHidden = true
        }
        enter.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func numbersOrOperatorsPressed(_ sender: UIButton) {
        if clear.currentTitle != "C" {
            clear.setTitle("C", for: .normal)
        }
        if numbers.contains(sender) {   // handles the case when entering a number
            // enable the disabled button
            if lastOperator != nil {
                setButton(lastOperator!, .white)
                lastOperator = nil
            }
            // handle the case for positive, nagative and decimal number
            switch sender.currentTitle! {
            case ".":
                if !lastInput.contains(".") {
                    lastInput += sender.currentTitle!
                }
            case "(-)":
                if !lastInput.hasPrefix("-") {
                    lastInput = "-" + lastInput
                }
            default:
                if lastInput == "0" {
                    lastInput = sender.currentTitle!
                } else if lastInput == "-0" {
                    lastInput = "-" + sender.currentTitle!
                } else {
                    lastInput += sender.currentTitle!
                }
            }
            resultText = lastInput
        } else {    // handles the case when an operator is pressed
            // enable the disabled button
            if lastOperator != nil {
                setButton(lastOperator!, .white)
                lastOperator = nil
            }
            // disable the pressed button
            lastOperator = sender
            setButton(sender, .yellow)
            // record the input number and operator
            checkIfValid(&lastInput)
            // record the operator
            if sender.currentTitle != "Enter" {
                calcOperator = sender.currentTitle!
            }
        }
        // display the input number
        resultArea.text = resultText
    }
    
    @IBAction func equalPressed(_ sender: UIButton) {
        // record the last input number if exists
        checkIfValid(&lastInput)
        
        if inputNumbers.count >= 2 || calcOperator.count > 1 {
            // enable the disabled button
            if lastOperator != nil {
                setButton(lastOperator!, .white)
                lastOperator = nil
            }
            // calculate the result
            var calcResult = 0.0
            var error = ""
            if calcOperator.count > 1 {     // multi-operand
                switch calcOperator {
                case "count":
                    calcResult = Double(inputNumbers.count)
                case "avg":
                    for i in 0...inputNumbers.count - 1 {
                        calcResult += inputNumbers[i]
                    }
                    calcResult = calcResult / Double(inputNumbers.count)
                default:
                    if inputNumbers.count == 1 && inputNumbers[0] >= 0.0 && inputNumbers[0] - Double(Int(inputNumbers[0])) == 0.0 {
                        calcResult = 1.0
                        for i in 1...Int.init(inputNumbers[0]) {
                            calcResult *= Double(i)
                        }
                    } else {
                        error = "Error"
                    }
                }
            } else {      // + - × ÷ %
                switch calcOperator {
                case "+":
                    calcResult = inputNumbers[0] + inputNumbers[1]
                case "−":
                    calcResult = inputNumbers[0] - inputNumbers[1]
                case "×":
                    calcResult = inputNumbers[0] * inputNumbers[1]
                case "÷":
                    if inputNumbers[1] != 0.0 {
                        calcResult = inputNumbers[0] / inputNumbers[1]
                    } else {
                        error = "Error"
                    }
                default:
                    if inputNumbers[1] != 0.0 {
                        let mod = Int(inputNumbers[0]) - (Int(inputNumbers[0]) / Int(inputNumbers[1])) * Int(inputNumbers[1])
                        calcResult = Double(mod)
                    } else {
                        error = "Error"
                    }
                }
            }
            // display result
            if error != "" {
                clearAction(clear, "AC", error)
                error = ""
            } else if calcResult - Double(Int(calcResult)) != 0.0 {
                clearAction(clear, "AC", calcResult)
            } else {
                clearAction(clear, "AC", Int(calcResult))
            }
        }
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        clearAction(sender, sender.currentTitle!, 0)
    }
    
    /* Takes the clear button, the button title and the text to display after the data
         has been cleaned as parameters. Clears all data or the last input number
         based on the button title, and displays the given text. */
    private func clearAction<IntDoubleString> (_ sender: UIButton, _ currentTitle: String, _ text: IntDoubleString) {
        // enable the disabled button
        if lastOperator != nil {
            setButton(lastOperator!, .white)
            lastOperator = nil
        }
        // record the last input number if exists
        if calcOperator != "" {
            checkIfValid(&lastInput)
        }
        
        if currentTitle == "AC" {   // clear everything
            calcOperator = ""
            inputNumbers.removeAll()
        } else if inputNumbers.count != 0 {     // clear the last input number
            inputNumbers.remove(at: inputNumbers.count - 1)
        }
        lastInput = "0"
        resultText = ""
        // display the result
        resultArea.text = String.init(describing: text)
        sender.setTitle("AC", for: .normal)
    }
    
    @IBAction func viewChanged(_ sender: UISegmentedControl) {
        // clear all previous data
        clearAction(clear, "AC", 0)
        
        switch sender.selectedSegmentIndex {
        case 1:
            hideOrDisplay(operators, true)
            hideOrDisplay(multiOperand, false)
            hideOrDisplay([enter], true)
        case 2:
            hideOrDisplay(operators, false)
            hideOrDisplay(multiOperand, true)
            hideOrDisplay([enter], false)
        default:
            hideOrDisplay(operators, false)
            hideOrDisplay(multiOperand, true)
            hideOrDisplay([enter], true)
        }
    }
    
    /* Takes an array of UIButtons and a Bool indicating whether to hide or display
         buttons as parameters. Hides or displays the button(s) accordingly. */
    private func hideOrDisplay(_ element: Array<UIButton>, _ hide: Bool) {
        if hide {
            for i in element {
                i.isHidden = true
            }
        } else {
            for i in element {
                i.isHidden = false
            }
        }
    }
    
    /* Takes a UIButton and an Optional UIColor as parameters. Enables or disables the
         button and changes its appearance. */
    private func setButton(_ button: UIButton, _ color: UIColor?) {
        button.isEnabled = !button.isEnabled
        button.setTitleColor(color, for: .normal)
    }
    
    /* Takes a string as parameter. Checks if the given string is a valid number. Records the number if it is valid, records 0.0 if not. */
    func checkIfValid(_ checkString: inout String) {
        if checkString != "0" {
            let range = checkString.startIndex..<checkString.endIndex
            let correctRange = checkString.range(of: "^[+-]?[0-9]+(.[0-9]?)?$", options: .regularExpression)
            if correctRange == range {
                inputNumbers.append(Double.init(checkString)!)
            } else {
                inputNumbers.append(0.0)
            }
        checkString = "0"
        }
    }
}


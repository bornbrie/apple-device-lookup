//
//  InputViewController.swift
//  Apple Device Lookup
//
//  Created by brianna on 2/5/18.
//  Copyright © 2018 Owly Design. All rights reserved.
//

import UIKit

class InputViewController: UITableViewController {
    
    let debug = true
    let finder = ModelFinder()
    
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    
    var resetBarButtonItem: UIBarButtonItem!
    var doneEditingBarButtonItem: UIBarButtonItem!
    
    /// The URL used to identify model identifiers
    var baseURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set error text to nil
        errorLabel.text = nil
        
        //Set baseURL WITHOUT last four of serial number appended
        baseURL = URL(string: "http://support-sp.apple.com/sp/product")
        
        // Set up reset button
        resetBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(InputViewController.didPressReset))
        resetBarButtonItem.tintColor = .white
        
        // Set up done editing button
        doneEditingBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(InputViewController.didPressDone))
        doneEditingBarButtonItem.tintColor = .white
        
        //Set textField delegate
        inputTextField.delegate = self
        
        // Open keyboard on inputTextField
//        inputTextField.becomeFirstResponder()
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    private func find() {
        
        // Initiate request for model name
        finder.getModelName(from: inputTextField.text) { unsafeModel, unsafeError in
            // If error is found, show error
            if let error = unsafeError {
                self.show(error: error)
                return
            }
            
            // Safely unwrap the model string
            guard let model = unsafeModel else {
                self.show(error: "Model was not found!")
                return
            }
            
            // Display model title
            self.show(model: model)
        }
    }

    /// Triggered when the user presses the 'Find' button on the UI. Invokes getModelName(from serialNumber: then complete: (_ model: String?, _ error: String?) -> Void
    ///
    /// - Parameter sender: UIButton instance that sent the action.
    @IBAction func didPressFind(_ sender: UIButton) {
        find()
    }
    
    @objc func didPressReset() {
        inputTextField.text = nil
        hideModel(then: nil)
    }
    
    @objc func didPressDone() {
        self.view.endEditing(false)
    }
    
    /// Shows an error with an animation. Hides and unhides the errorLabel inside a UIStackView while in an animation block, then uses the completion block to delay 3 seconds and hide the label again. Once that is finished the errorLabel's text is set to nil.
    ///
    /// - Parameter error: The error string to display
    private func show(error: String) {
        hideModel {
            // Set error text
            self.errorLabel.text = error
            
            // Show error animation
            UIView.animate(withDuration: 0.3, animations: {
                // Show error
                self.errorLabel.isHidden = false
                // Refresh constraints
                self.view.layoutIfNeeded()
                
                // Completion
            }) { finished in
                // Check if finished showing error
                if finished {
                    // Delay 3 seconds then hide error animation
                    UIView.animate(withDuration: 0.3, delay: 3, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                        // Hide error
                        self.errorLabel.isHidden = true
                        // Refresh constraints
                        self.view.layoutIfNeeded()
                        
                        // Completion
                    }, completion: { finished in
                        // Check if finished hiding error
                        if finished {
                            // Reset error to nil
                            self.errorLabel.text = nil
                        }
                    })
                }
            }
        }
    }
    
    private func show(model: String) {
        hideModel {
            // Set model text
            self.modelLabel.text = model
            
            // Show model animation
            UIView.animate(withDuration: 0.3) {
                // Show model
                self.modelLabel.isHidden = false
                // Show reset button
                self.navigationItem.rightBarButtonItem = self.resetBarButtonItem
                // Refresh constraints
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func hideModel(then complete: (()->())?) {
        
        if modelLabel.isHidden {
            if let safeComplete = complete {
                safeComplete()
            }
        }
        
        // Hide model animation
        UIView.animate(withDuration: 0.3, animations: {
            // Hide model
            self.modelLabel.isHidden = true
            // Show reset button
            self.navigationItem.rightBarButtonItem = nil
            // Refresh constraints
            self.view.layoutIfNeeded()
            
            // Completion
        }) { finished in
            
            // Check if finished hiding model
            if finished {
                // Reset model to nil
                self.modelLabel.text = nil
                
                if let safeComplete = complete {
                    safeComplete()
                }
            }
        }
    }
    
}

extension InputViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        find()
        view.endEditing(false)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.navigationItem.leftBarButtonItem = self.doneEditingBarButtonItem
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
}


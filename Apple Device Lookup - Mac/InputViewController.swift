//
//  InputViewController.swift
//  Apple Device Lookup - Mac
//
//  Created by brianna on 2/10/18.
//  Copyright © 2018 Owly Design. All rights reserved.
//

import Cocoa

class InputViewController: NSViewController {
    
    let debug = true
    let finder = ModelFinder()
    
    @IBOutlet weak var modelLabel: NSTextField!
    @IBOutlet weak var errorLabel: NSTextField!
    @IBOutlet weak var inputTextField: NSTextField!
    
    var resetBarButton: NSButton!
    var findButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set error text to nil
        errorLabel.stringValue = ""
        modelLabel.stringValue = ""
        
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        
        inputTextField.delegate = self
    }
    
    private func find() {
        
        // Initiate request for model name
        finder.getModelName(from: inputTextField.stringValue) { unsafeModel, unsafeError in
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
            
            self.errorLabel.stringValue = ""
            
            // Display model title
            self.modelLabel.stringValue = model
        }
    }
    
    /// Triggered when the user presses the 'Find' button on the UI. Invokes getModelName(from serialNumber: then complete: (_ model: String?, _ error: String?) -> Void
    ///
    /// - Parameter sender: UIButton instance that sent the action.
    @IBAction func didPressFind(_ sender: NSButton) {
        find()
    }
    
    @IBAction func didPressReset(_ sender: NSButton) {
        inputTextField.stringValue = ""
        modelLabel.stringValue = ""
        errorLabel.stringValue = ""
        
        // Show error
        self.errorLabel.isHidden = true
        
    }
    
    /// Shows an error with an animation. Hides and unhides the errorLabel inside a UIStackView while in an animation block, then uses the completion block to delay 3 seconds and hide the label again. Once that is finished the errorLabel's text is set to nil.
    ///
    /// - Parameter error: The error string to display
    private func show(error: String) {
        // Set error text
        self.errorLabel.stringValue = error
        // Show error
        self.errorLabel.isHidden = false
    }
}

extension InputViewController: NSTextFieldDelegate {
    
    override func controlTextDidChange(_ obj: Notification) {
        if
            let info = obj.userInfo,
            let text = info["NSFieldEditor"] as? NSText
        {
            
            text.string = text.string.uppercased()
        }
    }
}


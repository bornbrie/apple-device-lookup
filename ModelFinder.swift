//
//  ModelFinder.swift
//  Apple Device Lookup
//
//  Created by Brianna Lee on 3/20/18.
//  Copyright © 2018 Owly Design. All rights reserved.
//

import Foundation
import SWXMLHash
import Alamofire

class ModelFinder {
    
    static let baseURL = URL(string: "http://support-sp.apple.com/sp/product")!
    
    /// Uses Alamofire to send and return the url request, and uses SWXMLHash to parse the returned XML file.
    ///
    /// - Parameters:
    ///   - serialNumber: The 11 or 12 digit serial number, or alternatively the last 3 or 4 digits of either, respectively.
    ///   - complete: Call back block that returns the model name if no error is found, and an error if no model is found.
    func getModelName(from unsafeSerialNumber: String?, then complete: @escaping (_ model: String?, _ error: String?)->()) {
        
        // Check if Serial Number is not Nil or a blank String.
        guard
            let input = unsafeSerialNumber,
            input != ""
            else {
                complete(nil, "No Serial Number found")
                return
        }
        
        // If the Serial Number does not equal 3, 4, 11, or 12 digits, throw an error.
        guard input.count == 3 || input.count == 4 || input.count == 11 || input.count == 12 else {
            complete(nil, "Not a valid length")
            return
        }
        
        var serialNumber: String!
        
        // If the input was 11 characters...
        if input.count == 11 {
            // Take the last 3 characters
            serialNumber = String(input.suffix(3))
            
            // If the input was 12 characters...
        } else if input.count == 12 {
            // Take the last 4 characters
            serialNumber = String(input.suffix(4))
            
            // If the input was 3 or 4 characters
        } else {
            // Use the raw input
            serialNumber = input
        }
        
        // Construct URL Parameters
        let parameters: Parameters = ["cc" : serialNumber]
        
        // GET request url
        Alamofire.request("http://support-sp.apple.com/sp/product", parameters: parameters).response { response in
            // If an error is found...
            if let error = response.error {
                // Throw an error
                complete(nil, error.localizedDescription)
                return
            }
            
            // Safely unwrap data from response
            guard let data = response.data else {
                complete(nil, "Data was nil, no error was thrown. ABORT! ABORT!")
                return
            }
            
            // Encode response data into XMLIndexer from SWXMLHash
            let xml = SWXMLHash.parse(data)
            
            // Isolate the root dictionary from the xml collection
            let root = xml["root"]
            
            // Extract the model element
            guard let element = root["configCode"].element else {
                complete(nil, "Invalid input! Please try again.")
                return
            }
            
            // Cast the element to a String
            let model = element.text
            
            // Complete with model
            complete(model, nil)
        }
    }
}

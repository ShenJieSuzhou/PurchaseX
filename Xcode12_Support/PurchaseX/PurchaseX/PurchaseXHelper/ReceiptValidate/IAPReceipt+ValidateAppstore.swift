//
//  IAPReceipt+ValidateAppstore.swift
//  PurchaseX
//
//  Created by snaigame on 2021/8/22.
//

import Foundation
//import Alamofire

enum VerifyReceiptURLType: String {
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
}

extension IAPReceipt {
    
    /// Validate receipt via appstore
    /// - Parameters:
    ///   - sharedSecret: password
    ///   - isSandBox:  define sandbox env or production env
    /// - Returns:
    public func validateInAppstore(sharedSecret: String?, isSandBox: Bool, completion: @escaping(_ notification: PurchaseXNotification?, _ err: Error?) -> Void) {
        
        /// Start  validate
        let urlType: VerifyReceiptURLType = isSandBox ? .sandbox : .production
        let requestUrl = URL(string: urlType.rawValue)!
        let storeRequest = NSMutableURLRequest(url: requestUrl)
        storeRequest.httpMethod = "POST"
        
        var appStoreReceiptData: Data?
        // Get the receipt if it's available
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                appStoreReceiptData = receiptData
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                completion(.receiptValidationFailure, error)
                return
            }
        }
        
        let receiptString = appStoreReceiptData!.base64EncodedString(options: [])

        // Read receiptData
        let requestContents: NSMutableDictionary = ["receipt-data": receiptString]
        guard sharedSecret != nil else {
            completion(.receiptValidationFailure, nil)
            return
        }
        requestContents.setValue(sharedSecret, forKey: "password")
//        requestContents.setValue("application/json", forKey: "Content-type")
        
        do {
            storeRequest.httpBody = try JSONSerialization.data(withJSONObject: requestContents, options: [])
        } catch let error {
            completion(.receiptValidationFailure, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: storeRequest as URLRequest) { data, _, error -> Void in

            if let error = error {
                completion(.receiptValidationFailure, error)
                return
            }

            guard let safeData = data else {
                print("No remote data")
                completion(.receiptValidationFailure, nil)
                return
            }

            // data to json
            let str = String(decoding: safeData, as: UTF8.self)
            print(str)
        }
        
        task.resume()
    }
    
}

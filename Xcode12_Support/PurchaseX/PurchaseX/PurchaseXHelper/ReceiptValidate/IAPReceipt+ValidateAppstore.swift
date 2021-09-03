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

/// Validate Remotelly
extension IAPReceipt {
    
    /// Validate receipt via appstore
    /// - Parameters:
    ///   - sharedSecret: password
    ///   - isSandBox:  define sandbox env or production env
    ///   - completion: result handler
    /// - Returns:
    public func validateInAppstore(sharedSecret: String?, isSandBox: Bool, completion: @escaping(ReceiptValidationResult) -> Void) {
        
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
                completion(.error(error: error))
                return
            }
        } else {
            PXLog.event(.receiptValidationFailure)
            completion(.error(error: nil))
            return
        }
        
        // base64 encode
        let receiptString = appStoreReceiptData!.base64EncodedString(options: [])

        // Set request body
        let requestContents: NSMutableDictionary = ["receipt-data": receiptString]
        guard sharedSecret != nil else {
            completion(.error(error: nil))
            return
        }
        requestContents.setValue(sharedSecret, forKey: "password")
//        requestContents.setValue(true, forKey: "exclude-old-transactions")
        
        do {
            storeRequest.httpBody = try JSONSerialization.data(withJSONObject: requestContents, options: [])
        } catch let error {
            completion(.error(error: error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: storeRequest as URLRequest) { data, _, error -> Void in
            if let error = error {
                completion(.error(error: error))
                return
            }

            guard let safeData = data else {
                print("No remote data")
                completion(.error(error: nil))
                return
            }

            
            do{
                let json = try JSONSerialization.jsonObject(with: safeData, options: []) as? [String : Any]
                print("\(json)")
            }catch{
                print("erroMsg")
            }
            
            // data to json
            guard let response = try? JSONDecoder().decode(ReceiptValidationResponse.self, from: safeData) else {
                PXLog.event("No receipt data")
                completion(.error(error: nil))
                return
            }
            
            let status = response.status
            if status == 0 {
                
                response.latestReceiptInfo?.forEach({ info in
                    self.validatePurchasedProductIdentifiers.insert(info.productID)
                })
                
                completion(.success(receipt: response.receipt))
            } else if status == -2 {
                PXLog.event("Not decodable status.")
                completion(.error(error: nil))
            } else if status == -1 {
                PXLog.event("No status returned.")
                completion(.error(error: nil))
            } else if status == 21000 {
                PXLog.event("The request to the App Store was not made using the HTTP POST request method.")
                completion(.error(error: nil))
            } else if status == 21002 {
                PXLog.event("This status code is no longer sent by the App Store.")
                completion(.error(error: nil))
            } else if status == 21002 {
                PXLog.event("The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.")
                completion(.error(error: nil))
            } else if status == 21003 {
                PXLog.event("The receipt could not be authenticated.")
                completion(.error(error: nil))
            } else if status == 21004 {
                PXLog.event("The shared secret you provided does not match the shared secret on file for your account.")
                completion(.error(error: nil))
            } else if status == 21005 {
                PXLog.event("The receipt server was temporarily unable to provide the receipt. Try again.")
                completion(.error(error: nil))
            } else if status == 21006 {
                PXLog.event("This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.")
                completion(.error(error: nil))
            } else if status == 21007 {
                PXLog.event("This receipt is from the test environment, but it was sent to the production environment for verification.")
                completion(.error(error: nil))
            } else if status == 21008 {
                PXLog.event("This receipt is from the production environment, but it was sent to the test environment for verification.")
                completion(.error(error: nil))
            } else if status == 21009 {
                PXLog.event("Internal data access error. Try again later.")
                completion(.error(error: nil))
            } else if status == 21010 {
                PXLog.event("The user account cannot be found or has been deleted.")
                completion(.error(error: nil))
            }
        }
        
        task.resume()
    }
}

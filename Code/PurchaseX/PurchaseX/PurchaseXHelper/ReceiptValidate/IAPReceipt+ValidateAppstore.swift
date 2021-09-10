//
//  IAPReceipt+ValidateAppstore.swift
//  PurchaseX
//
//  Created by snaigame on 2021/8/22.
//

import Foundation

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
                completion(.error(error: ReceiptError.noReceiptData))
                return
            }
        } else {
            completion(.error(error: ReceiptError.noReceiptData))
            return
        }
        
        // base64 encode
        let receiptString = appStoreReceiptData!.base64EncodedString(options: [])

        // Set request body
        let requestContents: NSMutableDictionary = ["receipt-data": receiptString]
        guard sharedSecret != nil else {
            completion(.error(error: ReceiptError.secretNotMatching))
            return
        }
        requestContents.setValue(sharedSecret, forKey: "password")
        
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
                completion(.error(error: ReceiptError.noRemoteData))
                return
            }
                        
            // Convert json data to receipt model
            guard let response = try? JSONDecoder.receiptDecoder.decode(ReceiptValidationResponse.self, from: safeData) else {
                PXLog.event("No receipt data")
                completion(.error(error: ReceiptError.noReceiptData))
                return
            }
            
            let status = response.status
            let receiptError = ReceiptError(with: status)
            if status == 0 {
                response.latestReceiptInfo?.forEach({ info in
                    self.validatePurchasedProductIdentifiers.insert(info.productID!)
                })
                completion(.success(receipt: response.receipt))
            } else {
                completion(.error(error: receiptError))
            }
        }
        
        task.resume()
    }
}

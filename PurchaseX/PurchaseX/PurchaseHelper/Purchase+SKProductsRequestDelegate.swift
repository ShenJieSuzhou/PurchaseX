//
//  Purchase+SKProductsRequestDelegate.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/26.
//

import Foundation
import StoreKit

extension PurchaseManager: SKProductsRequestDelegate {
    
    /// Receive products from Appstore
    /// - Parameters:
    ///   - request: request object
    ///   - response: response from Appstore
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else {
            PXLog.event(.requestProductsFailure)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsNoProduct)
            }
        }
        
        guard response.invalidProductIdentifiers.isEmpty else {
            PXLog.event(.requestProductsInvalidProducts)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsInvalidProducts)
            }
        }
        
        // save the products returned from Appstore
        self.products = response.products
        PXLog.event(.requestProductsSuccess)
        DispatchQueue.main.async {
            self.requestProductsCompletion?(.requestProductsSuccess)
        }
    }
}

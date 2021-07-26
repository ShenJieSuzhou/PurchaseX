//
//  Purchase+SKProductsRequestDelegate.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/26.
//

import Foundation
import StoreKit

extension PurchaseXManager: SKProductsRequestDelegate {
    
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
            return
        }
        
        guard response.invalidProductIdentifiers.isEmpty else {
            PXLog.event(.requestProductsInvalidProducts)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsInvalidProducts)
            }
            return
        }
        
        // save the products returned from Appstore
        self.products = response.products
        PXLog.event(.requestProductsSuccess)
        DispatchQueue.main.async {
            self.requestProductsCompletion?(.requestProductsSuccess)
        }
    }
}

extension PurchaseXManager: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        
    }
}

extension PurchaseXManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    
}

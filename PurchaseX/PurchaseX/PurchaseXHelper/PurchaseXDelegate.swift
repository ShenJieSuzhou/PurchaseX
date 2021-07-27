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
    /// Listen transaction state
    /// - Parameters:
    ///   - queue: The payment queue object
    ///   - transactions: Transaction state
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                purchaseInProcess(transaction: transaction)
            case .purchased:
                purchaseCompleted(transaction: transaction)
            case .failed:
                purchaseFailed(transaction: transaction)
            case .restored:
                purchaseCompleted(transaction: transaction, restore: true)
            case .deferred:
                purchaseDeferred(transaction: transaction)
            @unknown default:
                return
            }
        }
    }
    
    
    ///  Purchase is in process
    /// - Parameter transaction: transaction object
    private func purchaseInProcess(transaction: SKPaymentTransaction){
        PXLog.event(.purchaseInProgress(productId: transaction.payment.productIdentifier))
        DispatchQueue.main.async {
            self.purchasingProductCompletion?(.purchaseInProgress(productId: transaction.payment.productIdentifier))
        }
    }
    
    /// Purchase is completed
    /// - Parameters:
    ///   - transaction: transtraction object
    ///   - restore: restore purchase
    private func purchaseCompleted(transaction: SKPaymentTransaction, restore: Bool = false) {
        
    }
    
    ///  Purchase failed
    /// - Parameter transaction: transaction object
    private func purchaseFailed(transaction: SKPaymentTransaction) {
        
    }
    
    /// Purchasse is pending
    /// - Parameter transaction: transaction object
    private func purchaseDeferred(transaction: SKPaymentTransaction) {
        
    }
    
}

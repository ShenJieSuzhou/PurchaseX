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
        DispatchQueue.main.async {
            self.products = response.products
            PXLog.event(.requestProductsSuccess)
            //self.requestProductsCompletion?(.requestProductsSuccess)
        }
    }
}

extension PurchaseXManager: SKRequestDelegate {
    
    public func requestDidFinish(_ request: SKRequest) {
        
        if productsRequest != nil {
            productsRequest = nil
            PXLog.event(.requestProductsDidFinish)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsDidFinish)
            }
            return
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        if productsRequest != nil {
            productsRequest = nil
            PXLog.event(.requestProductsFailure)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsFailure)
            }
            return
        }
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
        purchaseState = .inProgress
        DispatchQueue.main.async {
            self.purchasingProductCompletion?(.purchaseInProgress)
        }
    }
    
    /// Purchase is completed
    /// - Parameters:
    ///   - transaction: transtraction object
    ///   - restore: restore purchase
    private func purchaseCompleted(transaction: SKPaymentTransaction, restore: Bool = false) {
        defer {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        isPurchaseing = false
        purchaseState = .complete
        
        // restore or not
        guard let identifier = restore ? transaction.original?.payment.productIdentifier :
                transaction.payment.productIdentifier else {
                    
                    PXLog.event(restore ? .purchaseRestoreFailure : .purchaseFailure)
                    
                    if restore {
                        self.restorePurchasesCompletion?(.purchaseRestoreFailure)
                    } else {
                        DispatchQueue.main.async {
                            self.purchasingProductCompletion?(.purchaseFailure)
                        }
                    }
                    return
                }
        // Persist purchased productID
        
        // save purchased productID to our back list
     
        PXLog.event(restore ? .purchaseRestoreSuccess : .purchaseSuccess)
        if restore {
            DispatchQueue.main.async {
                self.restorePurchasesCompletion?(.purchaseRestoreSuccess)
            }
        } else {
            DispatchQueue.main.async {
                self.purchasingProductCompletion?(.purchaseSuccess)
            }
        }
    }
    
    ///  Purchase failed
    /// - Parameter transaction: transaction object
    private func purchaseFailed(transaction: SKPaymentTransaction) {
        defer {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        isPurchaseing = false
        purchaseState = .failed
        let identifier = transaction.payment.productIdentifier
        if let e = transaction.error as NSError? {
            if e.code == SKError.paymentCancelled.rawValue {
                PXLog.event(.purchaseCancelled)
                DispatchQueue.main.async {
                    self.purchasingProductCompletion?(.purchaseCancelled)
                }
            } else {
                PXLog.event(.purchaseFailure)
                DispatchQueue.main.async {
                    self.purchasingProductCompletion?(.purchaseFailure)
                }
            }
        } else {
            PXLog.event(.purchaseFailure)
            DispatchQueue.main.async {
                self.purchasingProductCompletion?(.purchaseFailure)
            }
        }
    }
    
    /// Purchasse is pending
    /// - Parameter transaction: transaction object
    private func purchaseDeferred(transaction: SKPaymentTransaction) {
        isPurchaseing = false
        purchaseState = .pending
        PXLog.event(.purchasePending)
        DispatchQueue.main.async {
            self.purchasingProductCompletion?(.purchasePending)
        }
    }
    
}

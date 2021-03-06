//
//  PurchaseXManagerImpl.swift
//  PurchaseX
//
//  Created by shenjie on 2021/9/22.
//

import Foundation
import StoreKit

final class PurchaseXManagerImpl: NSObject {
    
    // MARK: Purchasing completion handler
    // Completion handler when requesting products from appstore.
    internal var requestProductsCompletion: ((PurchaseXNotification) -> Void)? = nil
    
    // Completion handler when requesting a receipt refresh from appstore
    internal var requestReceiptCompletion: ((PurchaseXNotification) -> Void)? = nil

    // Completion handler when purchasing a product from appstore
    internal var purchasingProductCompletion: ((PurchaseXNotification) -> Void)? = nil

    // Completion handler when requesting appstore to restore purchases
    internal var restorePurchasesCompletion: ((PurchaseXNotification) -> Void)? = nil
    
    // Completion handler when validate receipt remotelly
    internal var validateRemoteCompletion: ((PurchaseXNotification) -> Void)? = nil
    
    /// Encapsulates the Appstore receipt located in the main bundle
    internal var receipt: IAPReceipt!
    /// Used to request product info from Appstore
    internal var productsRequest: SKProductsRequest?
    /// Used to request  a receipt refresh async from the Appstore
    internal var receiptRequest: SKRequest?
    
    private var products: [SKProduct]?
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// List of productIds read from the storekit configuration file.
    private var configuredProductIdentifiers: Set<String>?
    
    /// List of purchased productId
    private var purchasedProductIdentifiers = Set<String>()
    
    /// True if purchase is in Process
    private var isPurchaseing = false
    
    /// True if configuredProductId count > 0
    private var haveConfiguredProductIdentifiers: Bool {
        guard configuredProductIdentifiers != nil else {
            return false
        }
        return configuredProductIdentifiers!.count > 0 ? true : false
    }
    
    public var delegate: PurchaseXDelegate!
    
    /// True if appstore products have been retrived via function
    public var hasProducts: Bool {
        guard products != nil else {
            return false
        }

        return products!.count > 0 ? true : false
    }
    
    /// Product associated with productId
    public func product(from productId: String) -> SKProduct? {
        guard hasProducts else {
            return nil
        }
        
        let matchProduct = products!.filter { product in
            product.productIdentifier == productId
        }
        
        guard matchProduct.count == 1 else {
            return nil
        }
        
        return matchProduct.first
    }
    
    // MARK: - Initialization
    required override init() {
        super.init()
        
        SKPaymentQueue.default().add(self)

        // Load purchased products from UserDefault
        loadPurchasedProductIds()
    }
    
    func removeBroadcasters() {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - refreshReceipt
    /// Used when receipt validate failed
    /// - Parameter completion: a closure that will be called when the receipt has been refreshed.
    public func refreshReceipt(completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        requestReceiptCompletion = completion
        
        receiptRequest?.cancel()
        receiptRequest = SKReceiptRefreshRequest()
        receiptRequest?.delegate = self
        receiptRequest?.start()
        
        PXLog.event(.receiptRefreshStarted)
    }
    
    // MARK: - requestProductsFromAppstore
    /// - Request products form appstore
    /// - Parameter completion: a closure that will be called when the results returned from the appstore
    public func requestProductsFromAppstore(productIds: [String]?, completion: @escaping (_ notification: PurchaseXNotification?) -> Void) {
        // save request products info
        requestProductsCompletion = completion
        
        guard productIds != nil || productIds!.count > 0 else {
            PXLog.event(.productIdArrayEmpty)
            DispatchQueue.main.async {
                completion(.productIdArrayEmpty)
            }
            return
        }
        
        if products != nil {
            products?.removeAll()
        }
                
        configuredProductIdentifiers = Set(productIds!)
        
        // 1. Cancel pending requests
        productsRequest?.cancel()
        // 2. Init SKProductsRequest
        productsRequest = SKProductsRequest(productIdentifiers: configuredProductIdentifiers!)
        // 3. Set Delegate to receive the notification
        productsRequest!.delegate = self
        // 4. Start request
        productsRequest!.start()
    }
    
    // MARK: - purchase
    /// Start the process to purchase a product.
    /// - Parameter product: SKProduct object
    /// - Parameter completion: a closure that will be called when  purchase result returned from the appstore
    public func purchase(product: SKProduct, completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        // purchase handler
        purchasingProductCompletion = completion
        
        guard !isPurchaseing else {
            PXLog.event(.purchaseAbort)
            completion(.purchaseAbort)
            return
        }
        
        isPurchaseing = true
        
        // Start a purchase transaction
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        PXLog.event(.purchaseInProgress)
    }
    
    // MARK: - restorePurchase
    /// Ask Appstore to restore purchase
    /// - Parameter completion: a closure that will be called when  restore result returned from the appstore
    public func restorePurchase(completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        guard  !isPurchaseing else {
            return
        }
        
        restorePurchasesCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
        PXLog.event("Purchase restore started")
    }
    
    // MARK: - validateReceiptLocally
    /// Validate the receipt locally
    /// - Returns: true if validate successfully
    /// - Parameter completion: a closure that will be called when  receipt validation completely
    public func validateReceiptLocally(completion: @escaping(ReceiptValidationResult) -> Void) {
        PXLog.event("Start validate receipt locally")
        receipt = IAPReceipt()
        switch receipt.validateLocally() {
        case .success(let receipt):
            // Compare the backlist of purchased product with the validated purchased product
            // retrived from appstore
            self.createValidatedPurchasedProductIds(receipt: self.receipt)
            completion(.success(receipt: receipt))
        case .error(let error):
            completion(.error(error: error))
        }
    }
    
    // MARK: - validateReceiptRemotely
    /// Validate the receipt remotely
    /// - Parameters:
    ///   - shareSecret: share secret generate from appstore
    ///   - isSandBox: true if sandbox
    ///   - completion: a closure that will be called when  receipt validation completely
    public func validateReceiptRemotely(shareSecret: String?, isSandBox: Bool, completion: @escaping(ReceiptValidationResult) -> Void) {
        PXLog.event("Start validate receipt remotelly")
        receipt = IAPReceipt()
        receipt.validateInAppstore(sharedSecret: shareSecret, isSandBox: isSandBox) { validationResult in
            switch validationResult {
            case .success(let receipt):
                completion(.success(receipt: receipt))
            case .error(let error):
                completion(.error(error: error))
            }
        }
    }
    
    /// True if purchased
    /// - Parameter productId: productid
    /// - Returns:true if purchased
    public func isPurchased(productId: String) -> Bool {
        return purchasedProductIdentifiers.contains(productId)
    }
    
    /// Load purchased products from UserDefault
    private func loadPurchasedProductIds() {
        guard haveConfiguredProductIdentifiers else {
            PXLog.event("Purchased products load failed")
            return
        }
        
        purchasedProductIdentifiers = IAPPersistence.loadPurchasedProductIds(for: configuredProductIdentifiers!)
        PXLog.event("Purchased products load successed")
    }
    
    /// Get a localized price for product
    /// - Parameter product: SKProduct object
    /// - Returns: Localized price
    internal func getLocalizedPriceFor(product: SKProduct) -> String? {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = .behavior10_4
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        return priceFormatter.string(from: product.price)
    }
    
    internal func createValidatedPurchasedProductIds(receipt: IAPReceipt) {
        if purchasedProductIdentifiers == receipt.validatePurchasedProductIdentifiers {
            PXLog.event("Purchased Products do not match receipt")
        }

        IAPPersistence.resetPurchasedProductIds(from: purchasedProductIdentifiers, to: receipt.validatePurchasedProductIdentifiers)
        purchasedProductIdentifiers = receipt.validatePurchasedProductIdentifiers
    }
    
}

extension PurchaseXManagerImpl: SKProductsRequestDelegate {

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
            self.delegate.updateAvaliableProducts(avaliableProducts: self.products)
            
            PXLog.event(.requestProductsSuccess(products: self.products))
            self.requestProductsCompletion?(.requestProductsSuccess(products: self.products))
        }
    }
}


extension PurchaseXManagerImpl: SKRequestDelegate {

    public func requestDidFinish(_ request: SKRequest) {

        if productsRequest != nil {
            productsRequest = nil
            PXLog.event(.requestProductsDidFinish)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsDidFinish)
            }
            return
        }
        
        if receiptRequest != nil {
            receiptRequest = nil
            PXLog.event(.receiptRefreshFailure)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.receiptRefreshFailure)
            }
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
        
        if receiptRequest != nil {
            receiptRequest = nil
            PXLog.event(.receiptRefreshFailure)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.receiptRefreshFailure)
            }
        }
    }
}

extension PurchaseXManagerImpl: SKPaymentTransactionObserver {
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
//        purchaseState = .inProgress
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
//        purchaseState = .complete

        // restore or not
        guard let _ = restore ? transaction.original?.payment.productIdentifier :
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
        IAPPersistence.savePurchaseState(for: transaction.payment.productIdentifier)
        
        // save purchased productID to our back list
        purchasedProductIdentifiers.insert(transaction.payment.productIdentifier)
        
        PXLog.event(restore ? .purchaseRestoreSuccess : .purchaseSuccess)
        if restore {
            //  Store transaction
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
//        purchaseState = .failed
        
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

    /// Purchasse is delay
    /// - Parameter transaction: transaction object
    private func purchaseDeferred(transaction: SKPaymentTransaction) {
        isPurchaseing = false
//        purchaseState = .pending
        PXLog.event(.purchasePending)
        DispatchQueue.main.async {
            self.purchasingProductCompletion?(.purchasePending)
        }
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        PXLog.event("Restore operation finished")
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        PXLog.event("Restore operation failed: \(error)")
    }
}

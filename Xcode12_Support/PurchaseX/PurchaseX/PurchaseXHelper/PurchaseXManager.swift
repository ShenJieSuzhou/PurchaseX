//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit

public class PurchaseXManager: NSObject, ObservableObject {
    
    // MARK: Purchasing completion handler
    // Completion handler when requesting products from appstore.
    var requestProductsCompletion: ((PurchaseXNotification) -> Void)? = nil
    
    // Completion handler when requesting a receipt refresh from appstore
    var requestReceiptCompletion: ((PurchaseXNotification) -> Void)? = nil

    // Completion handler when purchasing a product from appstore
    var purchasingProductCompletion: ((PurchaseXNotification) -> Void)? = nil

    // Completion handler when requesting appstore to restore purchases
    var restorePurchasesCompletion: ((PurchaseXNotification) -> Void)? = nil
    
    
    // MARK: Property
    /// Array of products retrieved from AppleStore
    @Published public var products: [SKProduct]?
    
    /// Singleton access
//    public static let shareInstance: PurchaseXManager = PurchaseXManager()
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// the state of purchase
    public var purchaseState: PurchaseXState = .notStarted
    
    /// List of productIds read from the storekit configuration file.
    public var configuredProductIdentifiers: Set<String>?
    
    /// True if purchase is in Process
    public var isPurchaseing = false
    
    ///
    public var purchasedProductIdentifiers = Set<String>()
    
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
    
    
    /// Encapsulates the Appstore receipt located in the main bundle
    var receipt: IAPReceipt!
    /// Used to request product info from Appstore
    var productsRequest: SKProductsRequest?
    /// Used to request  a receipt refresh async from the Appstore
    var receiptRequest: SKRequest?
    
    
    
    public var count: Int = 0
        
    // MARK: - Initialization
    public override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        
        // Read productID from config plist file
        if let productIds = Configuration.readConfigFile() {
            PXLog.event(.requestProductsStarted)
            configuredProductIdentifiers = productIds

            // request products from Appstore
            self.requestProductsFromAppstore { notification in
                if notification == .requestProductsSuccess {

                }
            }
        }
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    /// - Request products form appstore
    /// - Parameter completion: a closure that will be called when the results returned from the appstore
    public func requestProductsFromAppstore(completion: @escaping (_ notification: PurchaseXNotification?) -> Void) {
        // save request products info
        requestProductsCompletion = completion
        
        guard configuredProductIdentifiers != nil || configuredProductIdentifiers!.count > 0 else {
            PXLog.event(.configurationEmpty)
            DispatchQueue.main.async {
                completion(.configurationEmpty)
            }
            return
        }
        
        if products != nil {
            products?.removeAll()
        }
                
        // 1. Cancel pending requests
        productsRequest?.cancel()
        // 2. Init SKProductsRequest
        productsRequest = SKProductsRequest(productIdentifiers: configuredProductIdentifiers!)
        // 3. Set Delegate to receive the notification
        productsRequest!.delegate = self
        // 4. Start request
        productsRequest!.start()
    }
    
    
    /// Start the process to purchase a product.
    /// - Parameter product: SKProduct object
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
    
    /// Ask Appstore to restore purchase
    public func restorePurchase() {
        
    }
    
    
    /// Validate the receipt issued by the Appstore
    /// - Returns: true if validate successfully
    public func processReceipt() -> Bool {
        
        receipt = IAPReceipt()
        
        guard receipt.isReachable,
              receipt.load(),
              receipt.validateSigning(),
              receipt.readReceipt(),
              receipt.validate() else {
                  PXLog.event(.transactionValidationFailure)
                  return false
              }
        
        // Persist the purchase history
        
        return true
    }
    
    /// Get a localized price for product
    /// - Parameter product: SKProduct object
    /// - Returns: Localized price
    public func getLocalizedPriceFor(product: SKProduct) -> String? {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = .behavior10_4
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        return priceFormatter.string(from: product.price)
    }
}

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

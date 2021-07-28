//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit

public class PurchaseXManager: NSObject,ObservableObject {
    
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
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// the state of purchase
    var purchaseState: PurchaseXState = .notStarted
    
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
    
    /// Used to request product info from Appstore
    var productsRequest: SKProductsRequest?
    
        
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
}

extension PurchaseXManager {
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
        PXLog.event(.requestProductsStarted)
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

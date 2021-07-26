//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit

public class PurchaseManager: ObservableObject {
    
    // MARK: Purchasing completion handler
    // Completion handler when requesting products from appstore.
    var requestProductsCompletion: ((PurchaseNotification) -> Void)? = nil
    
    // Completion handler when requesting a receipt refresh from appstore
    var requestReceiptCompletion: ((PurchaseNotification) -> Void)? = nil

    // Completion handler when purchasing a product from appstore
    var purchasingProductCompletion: ((PurchaseNotification) -> Void)? = nil

    // Completion handler when requesting appstore to restore purchases
    var restorePurchasesCompletion: ((PurchaseNotification) -> Void)? = nil
    
    
    // MARK: Property
    /// Array of products retrieved from AppleStore
    private var products: [SKProduct]?
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// the state of purchase
    var purchaseState: PurchaseState = .notStarted
    
    /// List of productIds read from the storekit configuration file.
    public var configuredProductIdentifiers: Set<String>?
    
    ///
    public var purchasedProductIdentifiers = Set<String>()
    
    /// True if appstore products have been retrived via function
    public var isAppstoreProductInfoAvailable: Bool {
        guard products == nil else {
            return false
        }
        guard products!.count > 0 else {
            return false
        }
        return true
    }
    
    /// Used to request product info from Appstore
    private var productsRequest: SKProductsRequest?
    
        
    // MARK: - Initialization
    init() {
        
//        SKPaymentQueue.default().add
        
        // Read productID from config plist file
        if let productIds = Configuration.readConfigFile() {
            PXLog.event(.requestProductsStarted)
            configuredProductIdentifiers = productIds
            
            
        }
    }
    
    deinit {
//        SKPaymentQueue.default().remove(self)
    }
}

extension PurchaseManager {
    public func requestProductsFromAppstore() {
        
    }
}

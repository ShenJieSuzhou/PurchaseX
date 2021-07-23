//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit

public class PurchaseManager {
    
    /// Array of products retrieved from AppleStore
    private var products: [Product]?
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// the state of purchase
    public var purchaseState: PurchaseState = .notStarted
    
    
    
    /// Return consumableProducts in the products array
    public var consumableProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type = .consumable
        })
    }
    
    // Return nonComsumableProducts in the products array
    public var nonConsumableProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type = .nonConsumable
        })
    }
    
    // Return auto-renewing subscription products in products array
    public var subscriptionProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type = .autoRenewable
        })
    }
    
    // MARK: - Initialization
    init() {
        // Read productID from config plist file
        if let productIds = Configuration.readConfigFile() {
            PXLog.event(.requestProductsStarted)
            
            
        }
    }
    
    /// Request products from Appstore by productID
    public func requestProductsFromAppstore(productIds: Set<String>) async -> [Product]? {
        
        return await Product.products(for: productIds)
    }
    
}

//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit


/// Get avaliable products
public protocol PurchaseXDelegate {
    func updateAvaliableProducts(avaliableProducts: [SKProduct]?)
}

public class PurchaseXManager:NSObject, ObservableObject {
    
    // MARK: Public Property
    /// Array of products retrieved from AppleStore
    @Published public var products: [Product]?
    
    public var consumableProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .consumable
        })
    }
    
    public var nonConsumbaleProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .nonRenewable
        })
    }
    
    public var subscriptionProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        return products?.filter({ product in
            product.type == .autoRenewable
        })
    }
    
    public var nonSubscriptionProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        return products?.filter({ product in
            product.type == .nonRenewable
        })
    }
    
    
    /// Object implement PurchaseXManager
    private var purchaseXManagerImpl: PurchaseXManagerImpl!
    
    // MARK: - Initialization
    public override init() {
        super.init()
        purchaseXManagerImpl = PurchaseXManagerImpl()
        purchaseXManagerImpl.delegate = self
                
    }

    deinit {
        purchaseXManagerImpl.removeBroadcasters()
    }
    
    // MARK: - refreshReceipt
    /// Used when receipt validate failed
    /// - Parameter completion: a closure that will be called when the receipt has been refreshed.
    public func refreshReceipt(completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        purchaseXManagerImpl.refreshReceipt(completion: completion)
    }
    
    // MARK: - requestProductsFromAppstore
    /// - Request products form appstore
    /// - Parameter productIds: a array saved productId
    /// - Parameter completion: a closure that will be called when the results returned from the appstore
    public func requestProductsFromAppstore(productIds: [String]){
        Task.init {
            products = await purchaseXManagerImpl.requestProductsFromAppstore(productIds: productIds)
            if products == nil, products?.count == 0 {
                PXLog.event(.requestProductsFailure)
            } else {
                PXLog.event(.requestProductsSuccess)
            }
        }
    }
    
    // MARK: - purchase
    /// Start the process to purchase a product.
    /// - Parameter product: SKProduct object
    /// - Parameter completion: a closure that will be called when  purchase result returned from the appstore
    public func purchase(product: SKProduct, completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        purchaseXManagerImpl.purchase(product: product, completion: completion)
    }
    
    // MARK: - restorePurchase
    /// Ask Appstore to restore purchase
    /// - Parameter completion: a closure that will be called when  restore result returned from the appstore
    public func restorePurchase(completion: @escaping(_ notification: PurchaseXNotification?) -> Void) {
        purchaseXManagerImpl.restorePurchase(completion: completion)
    }
    
    // MARK: - validateReceiptLocally
    /// Validate the receipt locally
    /// - Returns: true if validate successfully
    /// - Parameter completion: a closure that will be called when  receipt validation completely
    public func validateReceiptLocally(completion: @escaping(ReceiptValidationResult) -> Void) {
        purchaseXManagerImpl.validateReceiptLocally(completion: completion)
    }
    
    // MARK: - validateReceiptRemotely
    /// Validate the receipt remotely
    /// - Parameters:
    ///   - shareSecret: share secret generate from appstore
    ///   - isSandBox: true if sandbox
    ///   - completion: a closure that will be called when  receipt validation completely
    public func validateReceiptRemotely(shareSecret: String?, isSandBox: Bool, completion: @escaping(ReceiptValidationResult) -> Void) {
        purchaseXManagerImpl.validateReceiptRemotely(shareSecret: shareSecret, isSandBox: isSandBox, completion: completion)
    }
    
    // MARK: - extend function interface
    
    /// True if purchased
    /// - Parameter productId: productid
    /// - Returns:true if purchased
    public func isPurchased(productId: String) -> Bool {
        return purchaseXManagerImpl.isPurchased(productId: productId)
    }
    
    /// Product associated with productId
    public func product(from productId: String) -> SKProduct? {
        return purchaseXManagerImpl.product(from: productId)
    }
    
    /// True if appstore products have been retrived via function
    public func hasProducts() -> Bool {
        return purchaseXManagerImpl.hasProducts
    }
}

extension PurchaseXManager: PurchaseXDelegate {
    
    public func updateAvaliableProducts(avaliableProducts: [SKProduct]?) {
        if avaliableProducts != nil {
            self.products = avaliableProducts
        }
    }
}

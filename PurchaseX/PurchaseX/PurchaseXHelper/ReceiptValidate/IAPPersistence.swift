//
//  IAPPersistence.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/6.
//

import Foundation

public struct IAPPersistence: IAPPersistenceProtocol {
    /// Save the purchased state for a ProductId.
    static func savePurchaseState(for productId: String, purchased: Bool = true) {
        UserDefaults.standard.set(purchased, forKey: productId)
    }
    /// Save the purchased state for a set of ProductIds.
    static func savePurchaseState(for productIds: Set<String>, purchased: Bool = true) {
        productIds.forEach { productId in
            UserDefaults.standard.set(purchased, forKey: productId)
        }
    }
    /// Returns a Bool indicating if the ProductId has been purchased.
    static func loadPurchasedState(for productId: String) -> Bool {
        return UserDefaults.standard.bool(forKey: productId)
    }
    /// Returns the set of ProductIds that have been persisted to UserDefaults.
    static func loadPurchasedProductIds(for productIds: Set<String>) -> Set<String> {
        var purchasedProductIds = Set<String>()
        productIds.forEach { productId in
            let purchased = UserDefaults.standard.bool(forKey: productId)
            if purchased {
                purchasedProductIds.insert(productId)
            }
        }
        return purchasedProductIds
    }
    
    /// Removes the UserDefaults objects for the set of ProductIds. Then re-creates UserDefaults objects using
    /// the provided set of ProductIds.
    public static func resetPurchasedProductIds(from oldProductIds: Set<String>, to newProductIds: Set<String>, purchased: Bool = true) {
        oldProductIds.forEach { pid in
            UserDefaults.standard.removeObject(forKey: pid)
        }
        savePurchaseState(for: newProductIds, purchased: purchased)
    }
}

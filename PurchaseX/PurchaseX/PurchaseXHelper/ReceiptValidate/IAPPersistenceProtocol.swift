//
//  IAPPersistenceProtocol.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/6.
//

import Foundation

protocol IAPPersistenceProtocol {
    static func savePurchaseState(for productId: String, purchased: Bool)
    static func savePurchaseState(for productIds: Set<String>, purchased: Bool)
    static func loadPurchasedState(for productId: String) -> Bool
    static func loadPurchasedProductIds(for productIds: Set<String>) -> Set<String>
}

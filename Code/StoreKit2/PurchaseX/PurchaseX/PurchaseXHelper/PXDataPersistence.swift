//
//  PXDataPersistence.swift
//  PurchaseX
//
//  Created by shenjie on 2021/10/20.
//

import Foundation
import Security

/// We should   store consumables in keychain becase their transaction are NOT  stored in the receipt。

public struct ConsumableProductId: Hashable {
    let productId: String
    let count: Int
}

public struct PXDataPersistence {
    
}

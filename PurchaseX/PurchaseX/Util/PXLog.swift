//
//  PXLog.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation
import os.log

/// we use Apple's unified logging system to log errors, notifications and general messages.

public struct PXLog {
    private static let iapLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "StoreKit")
    
    public static func event(_ event: PurchaseXNotification) {
        #if DEBUG
        print(event.shortDescription())
        #else
        os_log("%{public}s", log: iapLog, type: .default, event.shortDescription())
        #endif
    }
    
    public static func event(_ event: PurchaseXNotification, productId: String) {
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId)")
        #else
        os_log("%{public}s for product %{public}s", log: iapLog, type: .default, event.shortDescription(), productId)
        #endif
    }
    
    public static func event(_ event: PurchaseXNotification, productId: String, webOrderLineItemId: String?) {
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId) with webOrderLineItemId \(webOrderLineItemId ?? "none")")
        #else
        os_log("%{public}s for product %{public}s with webOrderLineItemId %{public}s",
               log: storeLog,
               type: .default,
               event.shortDescription(),
               productId,
               webOrderLineItemId ?? "none")
        #endif
    }
    
    public static var transactionLog: Set<TransactionLog> = []
    
    public static func transaction(_ event: PurchaseXNotification, productId: String) {
        
        let t = TransactionLog(notification: event, productId: productId)
        if transactionLog.contains(t) { return }
        transactionLog.insert(t)
        
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId)")
        #else
        os_log("%{public}s for product %{public}s", log: storeLog, type: .default, event.shortDescription(), productId)
        #endif
    }
    
    public static func exception(_ exception: PurchaseXException, productId: String) {
        #if DEBUG
        print("\(exception.shortDescription()). For product \(productId)")
        #else
        os_log("%{public}s for product %{public}s", log: storeLog, type: .default, exception.shortDescription(), productId)
        #endif
    }
    
    public static func event(_ message: String) {
        #if DEBUG
        print(message)
        #else
        os_log("%s", log: storeLog, type: .info, message)
        #endif
    }
}


public struct TransactionLog: Hashable {
    
    let notification: PurchaseXNotification
    let productId: String
    
    public static func == (lhs: TransactionLog, rhs: TransactionLog) -> Bool {
        return (lhs.productId == rhs.productId) && (lhs.notification == rhs.notification)
    }
}

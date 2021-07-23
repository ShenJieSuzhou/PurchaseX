//
//  PurchaseException.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation

public enum StoreException: Error, Equatable {
    case purchaseException
    case purchaseInProgressException
    case transactionVerificationFailed
    
    public func shortDescription() -> String {
        switch self {
        case .purchaseException:
            return "Exception: StoreKit throw an exception while processing a purchase"
        case .purchaseInProgressException:
            return "Exception: You can't start another purchase yet, one is already in process"
        case .transactionVerificationFailed:
            return "Exception: A transaction failed Storekit's verification"
        }
    }
}

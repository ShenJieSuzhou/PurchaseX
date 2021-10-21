//
//  PurchaseNotification.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation
import StoreKit
import SwiftUI

/// From StoreNotification, if you are interesting about it , search StoreNotification on github。

public enum PurchaseXNotification: Error, Equatable {
    
    case requestProductsStarted
    case requestProductsSuccess
    case requestProductsFailure

    case purchaseInProgress
    case purchaseCancelled
    case purchasePending
    case purchaseSuccess
    case purchaseFailure
    
    case refundFailure
    case refundSuccess
    case refundUserCancel

    case resetConsumableInKeychainError
    case consumableKeychainError
    
    
    public func shortDescription() -> String {
        switch self {
            case .requestProductsStarted:          return "Request products from the App Store started"
            case .requestProductsSuccess:          return "Request products from the App Store success"
            case .requestProductsFailure:          return "Request products from the App Store failure"
                                
            case .purchaseInProgress:              return "Purchase in progress"
            case .purchasePending:                 return "Purchase in progress. Awaiting authorization"
            case .purchaseCancelled:               return "Purchase cancelled"
            case .purchaseSuccess:                 return "Purchase success"
            case .purchaseFailure:                 return "Purchase failure"
            
            case .refundFailure:                   return "Refund failure"
            case .refundSuccess:                   return "Refund success"
            case .refundUserCancel:                return "Refund user cancel"
            case .resetConsumableInKeychainError:  return "Consumable Products reset failed in the keychain"
            case .consumableKeychainError:         return "Keychain error"
        }
    }
}

//
//  PurchaseNotification.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation

/// From StoreNotification, if you are interesting about it , search StoreNotification on github。

public enum PurchaseNotification: Error, Equatable {
    
    case configurationNotFound
    case configurationEmpty
    case configurationSuccess
    case configurationFailure

    case requestProductsStarted
    case requestProductsSuccess
    case requestProductsFailure
    case requestProductsNoProduct
    case requestProductsInvalidProducts

    case purchaseAlreadyInProgress
    case purchaseInProgress
    case purchaseCancelled
    case purchasePending
    case purchaseSuccess
    case purchaseFailure

    case transactionReceived
    case transactionValidationSuccess
    case transactionValidationFailure
    case transactionFailure
    case transactionSuccess
    case transactionRevoked

    case consumableSavedInKeychain
    case consumableKeychainError
    
    
    public func shortDescription() -> String {
        switch self {
                
            case .configurationNotFound:           return "Configuration file not found in the main bundle"
            case .configurationEmpty:              return "Configuration file does not contain any product definitions"
            case .configurationSuccess:            return "Configuration success"
            case .configurationFailure:            return "Configuration failure"
                
            case .requestProductsStarted:          return "Request products from the App Store started"
            case .requestProductsSuccess:          return "Request products from the App Store success"
            case .requestProductsFailure:          return "Request products from the App Store failure"
            case .requestProductsNoProduct:        return "Request products from the App Store No Product"
            case .requestProductsInvalidProducts:  return "Request products from the App Store Invalid Products"
                
            case .purchaseAlreadyInProgress:       return "Purchase already in progress"
            case .purchaseInProgress:              return "Purchase in progress"
            case .purchasePending:                 return "Purchase in progress. Awaiting authorization"
            case .purchaseCancelled:               return "Purchase cancelled"
            case .purchaseSuccess:                 return "Purchase success"
            case .purchaseFailure:                 return "Purchase failure"
                
            case .transactionReceived:             return "Transaction received"
            case .transactionValidationSuccess:    return "Transaction validation success"
            case .transactionValidationFailure:    return "Transaction validation failure"
            case .transactionFailure:              return "Transaction failure"
            case .transactionSuccess:              return "Transaction success"
            case .transactionRevoked:              return "Transaction was revoked (refunded) by the App Store"
                
            case .consumableSavedInKeychain:       return "Consumable purchase successfully saved to the keychain"
            case .consumableKeychainError:         return "Keychain error"
        }
    }
}

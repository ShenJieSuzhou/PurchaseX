//
//  IAPReceipt+ValidateReceipt.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import Foundation


extension IAPReceipt {
    
    public func validate() -> Bool {
        
        guard let idString = bundleIdString,
              let version = bundleVersionString,
              let _ = opaqueData,
              let hash = hashData else {
            PXLog.event(.receiptValidationFailure)
                  return false
              }
        
        guard let appBundleId = Bundle.main.bundleIdentifier else {
            PXLog.event(.receiptValidationFailure)
            return false
        }
        
        guard idString == appBundleId else {
            PXLog.event(.receiptValidationFailure)
            return false
        }
        
        guard let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            PXLog.event(.receiptValidationFailure)
            return false
        }
        
        guard version == appVersionString else {
            PXLog.event(.receiptValidationFailure)
            return false
        }
        
        guard hash == computeHash() else {
            PXLog.event(.receiptValidationFailure)
            return false
        }
        
        if let expirarionDate = expirationDate {
            if expirarionDate < Date() {
                PXLog.event(.receiptValidationFailure)
                return false
            }
        }
        
        isValid = true
        PXLog.event(.receiptValidationSuccess)
        
        return true
    }
}

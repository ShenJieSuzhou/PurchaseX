//
//  IAPReceipt.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import UIKit

/// IAPReceipt is used to verify Appstore purchase receipts locally.
public class IAPReceipt {
    
    
    public var validatePurchasedProductIdentifiers = Set<String>()
    
    
    /// Check to see if the receipt's url is present and the receipt file is reachable
    public var isReachable: Bool {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            PXLog.event("Receipt cannot reachable")
            return false
        }
        
        PXLog.event("Receipt reachable at \(receiptUrl)")
        
        guard let _ = try? receiptUrl.checkResourceIsReachable() else {
            PXLog.event("Receipt file cannot find")
            return false
        }
        
        return true
    }
    
    /// True if valid, if false then the app should call refreshReceipt
    public var isValid = false
    
    // MARK: Private property
    
//    var inAppReceipts: []
    
    // Pointer to the receipt's PKCS7 data
    var receiptData: UnsafeMutablePointer<PKCS7>?
    
    // Required attribute type from receipt
    var bundleIdString: String?
    var bundleVersionString: String?
    var bundleIdData: Data?
    var hashData: Data?
    var opaqueData: Data?
    var expirationDate: Date?
    var receiptCreationDate: Date?
    var originalAppVersion: String?
    
    
    
    /// Get device identifier
    /// - Returns: Device identifier
    internal func getDeviceIdentifier() -> Data {
        let device = UIDevice.current
        var uuid = device.identifierForVendor!.uuid
        let addr = withUnsafePointer(to: &uuid) { (p) -> UnsafeRawPointer in
            UnsafeRawPointer(p)
        }
        let data = Data(bytes: addr, count: 16)
        return data
    }
    
    
    internal func computeHash() -> Data {
        let identifierData = getDeviceIdentifier()
        var ctx = SHA_CTX()
        SHA1_Init(&ctx)

        let identifierBytes: [UInt8] = .init(identifierData)
        SHA1_Update(&ctx, identifierBytes, identifierData.count)

        let opaqueBytes: [UInt8] = .init(opaqueData!)
        SHA1_Update(&ctx, opaqueBytes, opaqueData!.count)

        let bundleBytes: [UInt8] = .init(bundleIdData!)
        SHA1_Update(&ctx, bundleBytes, bundleIdData!.count)

        var hash: [UInt8] = .init(repeating: 0, count: 20)
        SHA1_Final(&hash, &ctx)
        return Data(bytes: hash, count: 20)
    }
}

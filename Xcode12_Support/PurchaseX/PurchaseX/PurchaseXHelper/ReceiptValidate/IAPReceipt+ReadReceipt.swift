//
//  IAPReceipt+ReadReceipt.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import Foundation

/// Reading Data in the Receipt
///  The contents of the payload is a set of ASN.1 values
///  Use openssl functions read this format
extension IAPReceipt {
    
    
    public func readReceipt() -> Bool {
        
        let receiptSign = receiptData?.pointee.d.sign
        let octets = receiptSign?.pointee.contents.pointee.d.data
        var pointer = UnsafePointer(octets?.pointee.data)
        let end = pointer!.advanced(by: Int(octets!.pointee.length))
        
        var type: Int32 = 0
        var xclass: Int32 = 0
        var length: Int = 0
        
        ASN1_get_object(&pointer, &length, &type, &xclass, pointer!.distance(to: end))
        guard type == V_ASN1_SET else {
            PXLog.event("receiptReadFailure")
            return false
        }
        
        while pointer! < end {
            ASN1_get_object(&pointer, &length, &type, &xclass, pointer!.distance(to: end))
            guard type == V_ASN1_SEQUENCE else {
                PXLog.event("receiptReadFailure")
                return false
            }
            
            guard let attributeType = IAPOpenSSL.asn1Int(p: &pointer, expectedLength: length) else {
                PXLog.event("receiptReadFailure")
                return false
            }
            
            guard let _ = IAPOpenSSL.asn1Int(p: &pointer, expectedLength: pointer!.distance(to: end)) else {
                PXLog.event("receiptReadFailure")
                return false
            }
            
            ASN1_get_object(&pointer, &length, &type, &xclass, pointer!.distance(to: end))
            guard type == V_ASN1_OCTET_STRING else {
                PXLog.event("receiptReadFailure")
                return false
            }
            
            var p = pointer
            switch IAPOpenSSLAttributeType(rawValue: attributeType) {
                    
                case .BudleVersion: bundleVersionString         = IAPOpenSSL.asn1String(    p: &p, expectedLength: length)
                case .ReceiptCreationDate: receiptCreationDate  = IAPOpenSSL.asn1Date(      p: &p, expectedLength: length)
                case .OriginalAppVersion: originalAppVersion    = IAPOpenSSL.asn1String(    p: &p, expectedLength: length)
                case .ExpirationDate: expirationDate            = IAPOpenSSL.asn1Date(      p: &p, expectedLength: length)
                case .OpaqueValue: opaqueData                   = IAPOpenSSL.asn1Data(      p: p!, expectedLength: length)
                case .ComputedGuid: hashData                    = IAPOpenSSL.asn1Data(      p: p!, expectedLength: length)
                    
                case .BundleIdentifier:
                    bundleIdString                              = IAPOpenSSL.asn1String(    p: &pointer, expectedLength: length)
                    bundleIdData                                = IAPOpenSSL.asn1Data(      p: pointer!, expectedLength: length)
                    
                case .IAPReceipt:
                    var iapStartPtr = pointer
                    let receiptProductInfo = IAPReceiptProductInfo(with: &iapStartPtr, payloadLength: length)
                    if let rpi = receiptProductInfo {
                        inAppReceipts.append(rpi)  // Cache in-app purchase record
                        if let pid = rpi.productIdentifier { validatePurchasedProductIdentifiers.insert(pid) }
                    }
                    
                default: break  // Ignore other attributes in receipt
            }
            
            // Advance pointer to the next item
            pointer = pointer!.advanced(by: length)
        }
        
        PXLog.event("receiptReadSuccess")
        
        return true
    }
    
    
}

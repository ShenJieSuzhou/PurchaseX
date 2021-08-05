//
//  IAPReceiptProductInfo.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/5.
//

import Foundation


/// Used to hold product info purchase from appstore
public struct IAPReceiptProductInfo {
    var quantity: Int?
    var productIdentifier: String?
    var transactionIdentifer: String?
    var originalTransactionIdentifier: String?
    var purchaseDate: Date?
    var originalPurchaseDate: Date?
    var subscriptionExpirationDate: Date?
    var subscriptionIntroductoryPricePeriod: Int?
    var subscriptionCancellationDate: Date?
    var webOrderLineId: Int?
    
    init?(with pointer: inout UnsafePointer<UInt8>?, payloadLength: Int) {
        let endPointer = pointer!.advanced(by: payloadLength)
        var type: Int32 = 0
        var xclass: Int32 = 0
        var length = 0
        
        ASN1_get_object(&pointer, &length, &type, &xclass, payloadLength)
        guard type == V_ASN1_SET else { return nil }
        
        while pointer! < endPointer {
            ASN1_get_object(&pointer, &length, &type, &xclass, pointer!.distance(to: endPointer))
            guard type == V_ASN1_SEQUENCE else { return nil }
            guard let attributeType = IAPOpenSSL.asn1Int(p: &pointer, expectedLength: pointer!.distance(to: endPointer)) else { return nil }
            guard let _ = IAPOpenSSL.asn1Int(p: &pointer, expectedLength: pointer!.distance(to: endPointer)) else { return nil }
            ASN1_get_object(&pointer, &length, &type, &xclass, pointer!.distance(to: endPointer))
            guard type == V_ASN1_OCTET_STRING else { return nil }

            var p = pointer
            switch IAPReceiptAttributeType(rawValue: attributeType) {
                case .Quantity: quantity                                            = IAPOpenSSL.asn1Int(   p: &p, expectedLength: length)
                case .ProductIdentifier: productIdentifier                          = IAPOpenSSL.asn1String(p: &p, expectedLength: length)
                case .TransactionIdentifer: transactionIdentifer                    = IAPOpenSSL.asn1String(p: &p, expectedLength: length)
                case .OriginalTransactionIdentifier: originalTransactionIdentifier  = IAPOpenSSL.asn1String(p: &p, expectedLength: length)
                case .PurchaseDate: purchaseDate                                    = IAPOpenSSL.asn1Date(  p: &p, expectedLength: length)
                case .OriginalPurchaseDate: originalPurchaseDate                    = IAPOpenSSL.asn1Date(  p: &p, expectedLength: length)
                case .SubscriptionExpirationDate: subscriptionExpirationDate        = IAPOpenSSL.asn1Date(  p: &p, expectedLength: length)
                case .SubscriptionCancellationDate: subscriptionCancellationDate    = IAPOpenSSL.asn1Date(  p: &p, expectedLength: length)
                case .WebOrderLineId: webOrderLineId                                = IAPOpenSSL.asn1Int(   p: &p, expectedLength: length)
                default: break
            }
            
            pointer = pointer!.advanced(by: length)
        }
    }
}

fileprivate enum IAPReceiptAttributeType: Int {
    
    case Quantity                       = 1701
    case ProductIdentifier              = 1702
    case TransactionIdentifer           = 1703
    case OriginalTransactionIdentifier  = 1705
    case PurchaseDate                   = 1704
    case OriginalPurchaseDate           = 1706
    case SubscriptionExpirationDate     = 1708
    case SubscriptionCancellationDate   = 1712
    case WebOrderLineId                 = 1711
}

//
//  PurchaseXConstants.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import Foundation

public struct PurchaseXConstants {
    
    public static func Certificate() -> String {
        #if DEBUG
        return "StoreKitTestCertificate"
        #else
        return "AppleIncRootCertificate"
        #endif
    }
    
    public static func CertificateExt() -> String { "cer" }
    
}

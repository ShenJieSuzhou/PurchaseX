//
//  IAPReceipt+ValidateReceipt.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import Foundation

/// Loading the receipt from the main bundle.
extension IAPReceipt {
    
    
    /// Load receipt from main bundle
    /// - Returns: return true if load sucess otherwise false
    public func load() -> Bool {
        
        // Get the url of the recept
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            PXLog.event("receiptLoadFailure")
            return false
        }
        
        // Read the receipt file as Data
        guard let data = try? Data(contentsOf: receiptUrl) else {
            PXLog.event("receiptLoadFailure")
            return false
        }
        
        // Using openssl create a buffer to read the PKCS7 container to
        let receiptBIO = BIO_new(BIO_s_mem())
        let receiptBytes: [UInt8] = .init(data)
        BIO_write(receiptBIO, receiptBytes, Int32(data.count))
        let receiptPKCS7 = d2i_PKCS7_bio(receiptBIO, nil)
        BIO_free(receiptBIO)
        
        guard receiptPKCS7 != nil else {
            PXLog.event("receiptLoadFailure")
            return false
        }
        
        // Check the PKCS7 container has a signature
        guard pkcs7IsSigned(pkcs7: receiptPKCS7!) else {
            PXLog.event("receiptLoadFailure")
            return false
        }
        
        // Check the PKCS7 container is of the correct data type
        guard pkcs7IsData(pkcs7: receiptPKCS7!) else {
            PXLog.event("receiptLoadFailure")
            return false
        }
        
        PXLog.event("receiptLoadSuccess")
        receiptData = receiptPKCS7
        
        return true
    }
    
    func pkcs7IsSigned(pkcs7: UnsafeMutablePointer<PKCS7>) -> Bool {
        // Convert the object in the PKCS7 struct to an Int32 and compare it to the OpenSSL NID constant
        OBJ_obj2nid(pkcs7.pointee.type) == NID_pkcs7_signed
    }
    
    func pkcs7IsData(pkcs7: UnsafeMutablePointer<PKCS7>) -> Bool {
        // Convert the object in the PKCS7 struct to an Int32 and compare it to the OpenSSL NID constant
        OBJ_obj2nid(pkcs7.pointee.d.sign.pointee.contents.pointee.type) == NID_pkcs7_data
    }
    
}

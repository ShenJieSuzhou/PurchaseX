//
//  IAPReceipt+ValidateAppleSigning.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/4.
//

import Foundation

/// Validating Apple Signed the Receipt
extension IAPReceipt {
    
    
    /// Loads Apple’s root certificate from the bundle and converts it to a BIO object.
    /// Verify a certificate in the chain from the root certificate signed the receipt
    /// - Returns: Returns true if correctly signed, false otherwise.
    public func validateSigning() -> Bool {
        
        guard receiptData != nil else {
            PXLog.event("receiptValidateSigningFailure")
            return false
        }
        
        guard let rootCertificateUrl = Bundle.main.url(forResource: PurchaseXConstants.Certificate(), withExtension: PurchaseXConstants.CertificateExt()), let rootCertificateData = try? Data(contentsOf: rootCertificateUrl) else {
            PXLog.event("receiptValidateSigningFailure")
            return false
        }
        
        let rootCertBio = BIO_new(BIO_s_mem())
        let rootCertBytes: [UInt8] = .init(rootCertificateData)
        BIO_write(rootCertBio, rootCertBytes, Int32(rootCertificateData.count))
        let rootCertX509 = d2i_X509_bio(rootCertBio, nil)
        BIO_free(rootCertBio)
        
        let store = X509_STORE_new()
        X509_STORE_add_cert(store, rootCertX509)
        
        OPENSSL_init_crypto(UInt64(OPENSSL_INIT_ADD_ALL_DIGESTS), nil)
        
        #if DEBUG
        let verificationResult = PKCS7_verify(receiptData, nil, store, nil, nil, PKCS7_NOCHAIN)
        #else
        let verificationResult = PKCS7_verify(receiptData, nil, store, nil, nil, nil)
        #endif

        if verificationResult == 1 {
            PXLog.event("receiptValidateSigningSuccess")
            
            return true
        }

        PXLog.event("receiptValidateSigningFailure")
        return false
    }
}

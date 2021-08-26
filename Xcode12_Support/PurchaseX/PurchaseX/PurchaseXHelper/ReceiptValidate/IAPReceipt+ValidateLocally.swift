//
//  IAPReceipt+ValidateLocally.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/26.
//

import Foundation


//MARK: - Validate Locally
extension IAPReceipt {
    
    
    /// Validate receipt locally
    /// - Parameter completion: result handler
    public func validateLocally(completion: @escaping(_ notification: PurchaseXNotification?, _ err: Error?) -> Void) {
        
        guard self.isReachable,
              self.load(),
              self.validateSigning(),
              self.readReceipt(),
              self.validate() else {
            
                PXLog.event(.receiptValidationFailure)
                completion(.receiptValidationFailure, nil)
                  return
              }
        completion(.receiptValidationSuccess, nil)
    }
    
    
    // MARK: - Loading the receipt from the main bundle.
    /// Returns: return true if load sucess otherwise false
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
    
    
    // MARK: - Validating Apple Signed the Receipt
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
        OPENSSL_add_all_algorithms_conf()
        
        #if DEBUG
        let verificationResult = PKCS7_verify(receiptData, nil, store, nil, nil, PKCS7_NOCHAIN)
        #else
        let verificationResult = PKCS7_verify(receiptData, nil, store, nil, nil, 0)
        #endif
        
        guard verificationResult == 1 else {
            PXLog.event("receiptValidateSigningFailure")
            return false
        }
        
        return true
    }
    
    
    // MARK: - Reading Data in the Receipt
    // The contents of the payload is a set of ASN.1 values
    // Use openssl functions read this format
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
    
    // MARK: - Validate Receipt
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

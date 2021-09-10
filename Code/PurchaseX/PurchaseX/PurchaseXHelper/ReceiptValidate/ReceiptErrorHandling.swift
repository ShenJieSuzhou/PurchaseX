//
//  ReceiptErrorHandling.swift
//  PurchaseX
//
//  Created by shenjie on 2021/9/10.
//


import Foundation

public enum ReceiptError: Int, Error {
    case noReceiptData
    case malformedReceipt
    // Local
    case emptyReceiptContents
    case receiptNotSigned
    case appleRootCertificateNotFound
    case receiptSignatureInvalid
    case malformedInAppPurchaseReceipt
    case incorrectHash
    case noReceiptObject
    // Server
    case noRemoteData
    case unknown
    case noStatus
    case jsonNotReadable
    case receiptCouldNotBeAuthenticated
    case secretNotMatching
    case receiptServerUnavailable
    case subscriptionExpired
    case testReceipt
    case productionEnvironment
    
    private enum ReceiptStatus: Int {
        case unknown = -2
        case none = -1
        case valid = 0
        case jsonNotReadable = 21000
        case malformedOrMissingData = 21002
        case receiptCouldNotBeAuthenticated = 21003
        case secretNotMatching = 21004
        case receiptServerUnavailable = 21005
        case subscriptionExpired = 21006
        case testReceipt = 21007
        case productionEnvironment = 21008
    }
    
    init?(with status: Int) {
        guard let statusObj = ReceiptStatus(rawValue: status) else {
            self = .unknown;
            return
        }
        
        switch statusObj {
        case .unknown, .valid:
            self = .unknown
        case .none:
            self = .noStatus
        case .jsonNotReadable:
            self = .jsonNotReadable
        case .malformedOrMissingData:
            self = .malformedReceipt
        case .receiptCouldNotBeAuthenticated:
            self = .receiptCouldNotBeAuthenticated
        case .secretNotMatching:
            self = .secretNotMatching
        case .receiptServerUnavailable:
            self = .receiptServerUnavailable
        case .testReceipt:
            self = .testReceipt
        case .productionEnvironment:
            self = .productionEnvironment
        case .subscriptionExpired:
            self = .subscriptionExpired
        }
    }
}

extension ReceiptError: CustomDebugStringConvertible {

    fileprivate var description: String {
        switch self {
        case .noReceiptData:
            return "IAP receipt data not found at `Bundle.main.appStoreReceiptURL`."
        case .emptyReceiptContents:
            return "Failed to extract the receipt contents from its PKCS #7 container."
        case .receiptNotSigned:
            return "The receipt that was extracted is not signed at all."
        case .appleRootCertificateNotFound:
            return "The application bundle doesn't have a copy of Apple’s root certificate to validate the signature with."
        case .receiptSignatureInvalid:
            return "The signature on the receipt is invalid because it doesn’t match against Apple’s root certificate."
        case .malformedReceipt:
            return "The extracted receipt contents do not match ASN.1 Set structure defined by Apple."
        case .malformedInAppPurchaseReceipt:
            return "The extracted receipt is not an ASN1 Set."
        case .incorrectHash:
            return "The extracted SHA1 hash is not identical to the receipt hash."
        case .noReceiptObject:
            return "Local validation success but init the receipt object failed."
        case .noRemoteData:
            return "No data received during server validation."
        case .unknown:
            return "Not decodable status."
        case .noStatus:
            return "No status returned."
        case .jsonNotReadable:
            return "The App Store could not read the JSON object you provided."
        case .receiptCouldNotBeAuthenticated:
            return "The receipt could not be authenticated."
        case .secretNotMatching:
            return "The receipt sharedSecret is invalid."
        case .receiptServerUnavailable:
            return "The receipt server is not currently available."
        case .subscriptionExpired:
            return "This receipt is valid but the subscription has expired."
        case .testReceipt:
            return "This receipt is from the test environment, but it was sent to the production environment for verification."
        case .productionEnvironment:
            return "This receipt is from the production environment, but it was sent to the test environment for verification."
        }
    }
    
    public var localizedDescription: String {
        return description
    }
    
    public var debugDescription: String {
        return "\(description)"
    }
}




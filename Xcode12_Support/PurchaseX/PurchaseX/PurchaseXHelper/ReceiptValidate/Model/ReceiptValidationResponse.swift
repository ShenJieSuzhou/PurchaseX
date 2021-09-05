//
//  ReceiptValidationResponse.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/25.
//


public struct ReceiptValidationResponse: Codable {
    let environment: String
    let receipt: Receipt?
    let latestReceiptInfo: [LatestReceiptInfo]?
    let latestReceipt: String
    let pendingRenewalInfo: [PendingRenewalInfo]?
    let status: Int

    enum CodingKeys: String, CodingKey {
        case environment, receipt
        case latestReceiptInfo = "latest_receipt_info"
        case latestReceipt = "latest_receipt"
        case pendingRenewalInfo = "pending_renewal_info"
        case status
    }
}

// MARK: - LatestReceiptInfo
public struct LatestReceiptInfo: Codable {
    let quantity, productID, transactionID, originalTransactionID, webOrderLineItemID: String?
    let purchaseDate, purchaseDatePst, originalPurchaseDate: Date?
    let purchaseDateMS: TimeInterval?
    let originalPurchaseDatePst: Date?
    let originalPurchaseDateMS: TimeInterval?
    let expiresDate, expiresDatePst: Date?
    let expiresDateMS: TimeInterval?
    let isTrialPeriod: Bool?
    let isInIntroOfferPeriod: Bool?
    let inAppOwnershipType: String?
    let subscriptionGroupIdentifier: String?

    enum CodingKeys: String, CodingKey {
        case quantity
        case productID = "product_id"
        case transactionID = "transaction_id"
        case originalTransactionID = "original_transaction_id"
        case purchaseDate = "purchase_date"
        case purchaseDateMS = "purchase_date_ms"
        case purchaseDatePst = "purchase_date_pst"
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMS = "original_purchase_date_ms"
        case originalPurchaseDatePst = "original_purchase_date_pst"
        case expiresDate = "expires_date"
        case expiresDateMS = "expires_date_ms"
        case expiresDatePst = "expires_date_pst"
        case webOrderLineItemID = "web_order_line_item_id"
        case isTrialPeriod = "is_trial_period"
        case isInIntroOfferPeriod = "is_in_intro_offer_period"
        case inAppOwnershipType = "in_app_ownership_type"
        case subscriptionGroupIdentifier = "subscription_group_identifier"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        quantity = try values.decodeIfPresent(String.self, forKey: .quantity)
        productID = try values.decodeIfPresent(String.self, forKey: .productID)
        transactionID = try values.decodeIfPresent(String.self, forKey: .transactionID)
        originalTransactionID = try values.decodeIfPresent(String.self, forKey: .originalTransactionID)
        webOrderLineItemID = try values.decodeIfPresent(String.self, forKey: .webOrderLineItemID)
        purchaseDate = try values.decodeIfPresent(Date.self, forKey: .purchaseDate)
        purchaseDateMS = {
            guard let str = try? values.decode(String.self, forKey: .purchaseDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        purchaseDatePst = try values.decodeIfPresent(Date.self, forKey: .purchaseDatePst)
        originalPurchaseDate = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDate)
        
        originalPurchaseDateMS = {
            guard let str = try? values.decode(String.self, forKey: .originalPurchaseDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        originalPurchaseDatePst = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDatePst)
        expiresDate = try values.decodeIfPresent(Date.self, forKey: .expiresDate)
        expiresDateMS = {
            guard let str = try? values.decode(String.self, forKey: .expiresDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
        expiresDatePst = try values.decodeIfPresent(Date.self, forKey: .expiresDatePst)
        if let isTrialPeriodString = try values.decodeIfPresent(String.self, forKey: .isTrialPeriod) {
            isTrialPeriod = Bool(isTrialPeriodString)
        } else{
            isTrialPeriod = nil
        }
        if let isInIntroOfferPeriodString = try values.decodeIfPresent(String.self, forKey: .isInIntroOfferPeriod) {
            isInIntroOfferPeriod = Bool(isInIntroOfferPeriodString)
        } else {
            isInIntroOfferPeriod = nil
        }
        inAppOwnershipType = try values.decodeIfPresent(String.self, forKey: .inAppOwnershipType)
        subscriptionGroupIdentifier = try values.decodeIfPresent(String.self, forKey: .subscriptionGroupIdentifier)
    }
}

// MARK: - PendingRenewalInfo
public struct PendingRenewalInfo: Codable {
    let expirationIntent, autoRenewProductID, isInBillingRetryPeriod, productID: String
    let originalTransactionID, autoRenewStatus: String

    enum CodingKeys: String, CodingKey {
        case expirationIntent = "expiration_intent"
        case autoRenewProductID = "auto_renew_product_id"
        case isInBillingRetryPeriod = "is_in_billing_retry_period"
        case productID = "product_id"
        case originalTransactionID = "original_transaction_id"
        case autoRenewStatus = "auto_renew_status"
    }
}

// MARK: - Receipt
public struct Receipt: Codable {
    let receiptType: String?
    let adamID, appItemID: Int?
    let bundleID, applicationVersion: String?
    let downloadID, versionExternalIdentifier: Int?
    let receiptCreationDate, receiptCreationDatePst, requestDate: Date?
    let receiptCreationDateMS: TimeInterval?
    let requestDatePst, originalPurchaseDate: Date?
    let requestDateMS: TimeInterval?
    let originalPurchaseDateMS: TimeInterval?
    let originalPurchaseDatePst: Date?
    let originalApplicationVersion: String?
    let receiptExpirationDate: Date?
    let inApp: [LatestReceiptInfo]?
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        receiptType = try values.decodeIfPresent(String.self, forKey: .receiptType)
        adamID = try values.decodeIfPresent(Int.self, forKey: .adamID)
        appItemID = try values.decodeIfPresent(Int.self, forKey: .appItemID)
        bundleID = try values.decodeIfPresent(String.self, forKey: .bundleID)
        applicationVersion = try values.decodeIfPresent(String.self, forKey: .applicationVersion)
        downloadID = try values.decodeIfPresent(Int.self, forKey: .downloadID)
        versionExternalIdentifier = try values.decodeIfPresent(Int.self, forKey: .versionExternalIdentifier)
        receiptCreationDate = try values.decodeIfPresent(Date.self, forKey: .receiptCreationDate)
        receiptCreationDatePst = try values.decodeIfPresent(Date.self, forKey: .receiptCreationDatePst)
        requestDate = try values.decodeIfPresent(Date.self, forKey: .requestDate)
        receiptCreationDateMS = {
            guard let str = try? values.decode(String.self, forKey: .receiptCreationDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
        requestDatePst = try values.decodeIfPresent(Date.self, forKey: .requestDatePst)
        originalPurchaseDate = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDate)
        
        requestDateMS = {
            guard let str = try? values.decode(String.self, forKey: .requestDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
        originalPurchaseDateMS = {
            guard let str = try? values.decode(String.self, forKey: .originalPurchaseDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
        originalPurchaseDatePst = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDatePst)
        originalApplicationVersion = try values.decodeIfPresent(String.self, forKey: .originalApplicationVersion)
        receiptExpirationDate = try values.decodeIfPresent(Date.self, forKey: .receiptExpirationDate)
        inApp = try? values.decode([LatestReceiptInfo].self, forKey: .inApp)
    }
    
    init?(bundleID: String?,
          appVersion: String?,
          originalAppVersion: String?,
          inAppPurchaseReceipts:[LatestReceiptInfo],
          receiptCreationDate: Date?,
          expirationDate: Date?) {
        
        guard let bundleID = bundleID,
              let appVersion = appVersion,
              let originalAppVersion = originalAppVersion,
              let receiptCreationDate = receiptCreationDate else {
            return nil
        }
        
        self.bundleID = bundleID
        self.applicationVersion = appVersion
        self.inApp = inAppPurchaseReceipts
        self.originalApplicationVersion = originalAppVersion
        self.receiptCreationDate = receiptCreationDate
        self.receiptCreationDatePst = receiptCreationDate
        self.receiptCreationDateMS = nil
        self.receiptExpirationDate = expirationDate
        self.originalPurchaseDate = nil
        self.originalPurchaseDatePst = nil
        self.originalPurchaseDateMS = nil
        self.requestDate = nil
        self.requestDatePst = nil
        self.requestDateMS = nil
        self.appItemID = nil
        self.adamID = nil
        self.versionExternalIdentifier = nil
        self.downloadID = nil
        self.receiptType = nil
    }

    enum CodingKeys: String, CodingKey {
        case receiptType = "receipt_type"
        case adamID = "adam_id"
        case appItemID = "app_item_id"
        case bundleID = "bundle_id"
        case applicationVersion = "application_version"
        case downloadID = "download_id"
        case versionExternalIdentifier = "version_external_identifier"
        case receiptCreationDate = "receipt_creation_date"
        case receiptCreationDateMS = "receipt_creation_date_ms"
        case receiptCreationDatePst = "receipt_creation_date_pst"
        case requestDate = "request_date"
        case requestDateMS = "request_date_ms"
        case requestDatePst = "request_date_pst"
        case originalPurchaseDate = "original_purchase_date"
        case originalPurchaseDateMS = "original_purchase_date_ms"
        case originalPurchaseDatePst = "original_purchase_date_pst"
        case originalApplicationVersion = "original_application_version"
        case inApp = "in_app"
        case receiptExpirationDate = "expiration_date"
    }
}

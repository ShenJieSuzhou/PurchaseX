//
//  ReceiptValidationResponse.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/25.
//
//  https://developer.apple.com/documentation/appstorereceipts/responsebody/receipt

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
    let cancellationDate, cancellationDatePst: Date?
    let cancellationDateMs: TimeInterval?
    let cancellationReason: String?
    let isTrialPeriod: String?
    let isInIntroOfferPeriod: String?
    let inAppOwnershipType: String?
    let subscriptionGroupIdentifier: String?
    let isUpgraded: String?
    let offerCodeRefName: String?
    let promotionalOfferId: String?
    let appAccountToken: String?

    enum CodingKeys: String, CodingKey {
        case quantity = "quantity"
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
        case cancellationDate = "cancellation_date"
        case cancellationDatePst = "cancellation_date_pst"
        case cancellationDateMs = "cancellation_date_ms"
        case cancellationReason = "cancellation_reason"
        case webOrderLineItemID = "web_order_line_item_id"
        case isTrialPeriod = "is_trial_period"
        case isInIntroOfferPeriod = "is_in_intro_offer_period"
        case inAppOwnershipType = "in_app_ownership_type"
        case subscriptionGroupIdentifier = "subscription_group_identifier"
        case isUpgraded = "is_upgraded"
        case offerCodeRefName = "offer_code_ref_name"
        case promotionalOfferId = "promotional_offer_id"
        case appAccountToken = "app_account_token"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        quantity = try values.decodeIfPresent(String.self, forKey: .quantity)
        productID = try values.decodeIfPresent(String.self, forKey: .productID)
        transactionID = try values.decodeIfPresent(String.self, forKey: .transactionID)
        originalTransactionID = try values.decodeIfPresent(String.self, forKey: .originalTransactionID)
        webOrderLineItemID = try values.decodeIfPresent(String.self, forKey: .webOrderLineItemID)
        // purchase date
        purchaseDate = try values.decodeIfPresent(Date.self, forKey: .purchaseDate)
        purchaseDateMS = {
            guard let str = try? values.decode(String.self, forKey: .purchaseDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        purchaseDatePst = try values.decodeIfPresent(Date.self, forKey: .purchaseDatePst)
        //original purchase date
        originalPurchaseDate = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDate)
        originalPurchaseDateMS = {
            guard let str = try? values.decode(String.self, forKey: .originalPurchaseDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        originalPurchaseDatePst = try values.decodeIfPresent(Date.self, forKey: .originalPurchaseDatePst)
        //expires date
        expiresDate = try values.decodeIfPresent(Date.self, forKey: .expiresDate)
        expiresDateMS = {
            guard let str = try? values.decode(String.self, forKey: .expiresDateMS) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        expiresDatePst = try values.decodeIfPresent(Date.self, forKey: .expiresDatePst)
        //cancellation date
        cancellationDate = try values.decodeIfPresent(Date.self, forKey: .cancellationDate)
        cancellationDateMs = {
            guard let str = try? values.decode(String.self, forKey: .cancellationDateMs) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        cancellationDatePst = try values.decodeIfPresent(Date.self, forKey: .cancellationDatePst)
        cancellationReason = try values.decodeIfPresent(String.self, forKey: .cancellationReason)
        
        isTrialPeriod = try values.decodeIfPresent(String.self, forKey: .isTrialPeriod)
            
        isInIntroOfferPeriod = try values.decodeIfPresent(String.self, forKey: .isInIntroOfferPeriod)
        inAppOwnershipType = try values.decodeIfPresent(String.self, forKey: .inAppOwnershipType)
        subscriptionGroupIdentifier = try values.decodeIfPresent(String.self, forKey: .subscriptionGroupIdentifier)
        
        isUpgraded = try values.decodeIfPresent(String.self, forKey: .isUpgraded)
        
        offerCodeRefName = try values.decodeIfPresent(String.self, forKey: .offerCodeRefName)
        promotionalOfferId = try values.decodeIfPresent(String.self, forKey: .promotionalOfferId)
        appAccountToken = try values.decodeIfPresent(String.self, forKey: .appAccountToken)
    }
    
    public init?(quantity: Int?,
          productIdentifier: String?,
          transactionIdentifier: String?,
          originalTransactionIdentifier: String?,
          purchaseDate: Date?,
          originalPurchaseDate: Date?,
          subscriptionExpirationDate: Date?,
          subscriptionIntroductoryPricePeriod: Int?,
          cancellationDate: Date?,
          webOrderLineItemId: String?) {
        
        guard let quantity = quantity,
            let productIdentifier = productIdentifier,
            let transactionIdentifier = transactionIdentifier else {
                return nil
        }
        
        self.quantity = String(quantity)
        self.productID = productIdentifier
        self.transactionID = transactionIdentifier
        self.originalTransactionID = originalTransactionIdentifier
        
        self.purchaseDate = purchaseDate
        self.purchaseDatePst = purchaseDate
        self.purchaseDateMS = purchaseDate?.timeIntervalSince1970
        
        self.originalPurchaseDate = originalPurchaseDate
        self.originalPurchaseDatePst = originalPurchaseDate
        self.originalPurchaseDateMS = originalPurchaseDate?.timeIntervalSince1970

        self.expiresDate = subscriptionExpirationDate
        self.expiresDatePst = subscriptionExpirationDate
        self.expiresDateMS = subscriptionExpirationDate?.timeIntervalSince1970

        self.isInIntroOfferPeriod = subscriptionIntroductoryPricePeriod == 1 ? "true" : "false"
        self.cancellationDate = cancellationDate
        self.webOrderLineItemID = webOrderLineItemId

        self.cancellationReason = nil
        self.isTrialPeriod = nil
        self.cancellationDatePst = nil
        self.cancellationDateMs = nil
        self.inAppOwnershipType = nil
        self.subscriptionGroupIdentifier = nil
        self.isUpgraded = nil
        self.offerCodeRefName = nil
        self.promotionalOfferId = nil
        self.appAccountToken = nil
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
    let receiptExpirationDate, expirationDatePst: Date?
    let expirationDateMs: TimeInterval?
    let preorderDate, preorderDatePst: Date?
    let preorderDateMs: TimeInterval?
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
        expirationDatePst = try values.decodeIfPresent(Date.self, forKey: .expirationDatePst)
        expirationDateMs = {
            guard let str = try? values.decode(String.self, forKey: .expirationDateMs) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
        preorderDate = try values.decodeIfPresent(Date.self, forKey: .preorderDate)
        preorderDatePst = try values.decodeIfPresent(Date.self, forKey: .preorderDatePst)
        preorderDateMs = {
            guard let str = try? values.decode(String.self, forKey: .preorderDateMs) else { return nil }
            return TimeInterval(millisecondsString: str)
        }()
        
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
        self.expirationDateMs = nil
        self.expirationDatePst = nil
        self.preorderDate = nil
        self.preorderDateMs = nil
        self.preorderDatePst = nil
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
        case expirationDatePst = "expiration_date_pst"
        case expirationDateMs = "expiration_date_ms"
        case preorderDate = "preorder_date"
        case preorderDateMs = "preorder_date_ms"
        case preorderDatePst = "preorder_date_pst"
    }
}

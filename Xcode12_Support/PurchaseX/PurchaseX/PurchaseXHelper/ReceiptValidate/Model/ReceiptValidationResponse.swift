//
//  ReceiptValidationResponse.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/25.
//


struct ReceiptValidationResponse: Codable {
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
struct LatestReceiptInfo: Codable {
    let quantity, productID, transactionID, originalTransactionID: String
    let purchaseDate, purchaseDateMS, purchaseDatePst, originalPurchaseDate: String
    let originalPurchaseDateMS, originalPurchaseDatePst: String
    let expiresDate, expiresDateMS, expiresDatePst, webOrderLineItemID: String?
    let isTrialPeriod: String
    let isInIntroOfferPeriod: String?
    let inAppOwnershipType: InAppOwnershipType
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
}

enum InAppOwnershipType: String, Codable {
    case purchased = "PURCHASED"
}

// MARK: - PendingRenewalInfo
struct PendingRenewalInfo: Codable {
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
struct Receipt: Codable {
    let receiptType: String
    let adamID, appItemID: Int
    let bundleID, applicationVersion: String
    let downloadID, versionExternalIdentifier: Int
    let receiptCreationDate, receiptCreationDateMS, receiptCreationDatePst, requestDate: String
    let requestDateMS, requestDatePst, originalPurchaseDate, originalPurchaseDateMS: String
    let originalPurchaseDatePst, originalApplicationVersion: String
    let inApp: [LatestReceiptInfo]

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
    }
}

//
//  PurchaseXManagerImpl.swift
//  PurchaseX
//
//  Created by shenjie on 2021/9/22.
//

import Foundation
import StoreKit

final class PurchaseXManagerImpl: NSObject {
    
    private var products: [Product]?
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    /// List of productIds read from the storekit configuration file.
    private var configuredProductIdentifiers: Set<String>?
        
    /// True if purchase is in Process
    private var isPurchaseing = false
    
    /// Handle for App Store transactions
    private var transactionListener: Task<Void, Error>? = nil
    
    /// True if configuredProductId count > 0
    private var haveConfiguredProductIdentifiers: Bool {
        guard configuredProductIdentifiers != nil else {
            return false
        }
        return configuredProductIdentifiers!.count > 0 ? true : false
    }
    
    /// True if appstore products have been retrived via function
    public var hasProducts: Bool {
        guard products != nil else {
            return false
        }

        return products!.count > 0 ? true : false
    }
    
    /// Product associated with productId
    public func product(from productId: String) -> Product? {
        guard hasProducts else {
            return nil
        }
        
        let matchProduct = products!.filter { product in
            product.id == productId
        }
        
        guard matchProduct.count == 1 else {
            return nil
        }
        
        return matchProduct.first
    }
    
    // MARK: - Initialization
    required override init() {
        super.init()
        // Listen for App Store transactions
        transactionListener = handTransaction()
        
        // Load purchased products from UserDefault
        loadPurchasedProductIds()
    }
    
    func removeBroadcasters() {
        transactionListener?.cancel()
    }
    
    
    // MARK: - requestProductsFromAppstore
    /// - Request products form appstore
    /// - Parameter completion: a closure that will be called when the results returned from the appstore
    @MainActor public func requestProductsFromAppstore(productIds: [String]) async -> [Product]? {
        products = try? await Product.products(for: Set.init(productIds))
        return products
    }
    
    // MARK: - purchase
    /// Start the process to purchase a product.
    /// - Parameter product: Product object
    public func purchase(product: Product) async throws -> (transaction: Transaction?, purchaseState: PurchaseXState){
        guard !isPurchaseing else {
            throw PurchaseXException.purchaseInProgressException
        }
        
        isPurchaseing = true
        
        // Start a purchase transaction
        guard let result = try? await product.purchase() else {
            throw PurchaseXException.purchaseException
        }
        
        switch result {
        case .success(let verificationResult):
            let checkResult = checkTransactionVerficationResult(result: verificationResult)
            if !checkResult.verified {
                throw PurchaseXException.transactionVerificationFailed
            }
            
            let validatedTransaction = checkResult.transaction
            
            await validatedTransaction.finish()
            
            // Because consumable's transaction are not stored in the receipt, So treat differerntly
            if validatedTransaction.productType == .consumable {
                
            }
            return (transaction: validatedTransaction, purchaseState: .complete)
        case .userCancelled:
            return (transaction: nil, purchaseState: .cancelled)
        case .pending:
            return (transaction: nil, purchaseState: .pending)
        default:
            return (transaction: nil, purchaseState: .unknown)
        }
    }
        
    /// True if purchased
    /// - Parameter productId: productid
    /// - Returns:true if purchased
    public func isPurchased(productId: String) async throws -> Bool {
        return false
//        guard let product  = product(from: productId) else {
//            return false
//        }
//
//        if product.type == .consumable {
//            return true
//        }
//
//        return purchasedProductIdentifiers.contains(productId)
    }
    
    /// Load purchased products from UserDefault
    private func loadPurchasedProductIds() {
//        guard haveConfiguredProductIdentifiers else {
//            PXLog.event("Purchased products load failed")
//            return
//        }
//
//        purchasedProductIdentifiers = IAPPersistence.loadPurchasedProductIds(for: configuredProductIdentifiers!)
//        PXLog.event("Purchased products load successed")
    }
    
    /// Get a localized price for product
    /// - Parameter product: SKProduct object
    /// - Returns: Localized price
    internal func getLocalizedPriceFor(product: SKProduct) -> String? {
        let priceFormatter = NumberFormatter()
        priceFormatter.formatterBehavior = .behavior10_4
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = product.priceLocale
        return priceFormatter.string(from: product.price)
    }
    
    
    private func handTransaction() -> Task<Void, Error> {

        return Task.detached{
            for await verificationResult in Transaction.updates {
                let checkResult = self.checkTransactionVerficationResult(result: verificationResult)
                
                if checkResult.verified {
                    let validatedTransaction = checkResult.transaction
                    await self.updatePurchasedIdentifiers(validatedTransaction)
                    await validatedTransaction.finish()
                } else {
                    
                }
            }
        }
    }

    private func checkTransactionVerficationResult(result: VerificationResult<Transaction>) -> (transaction: Transaction, verified: Bool) {
        switch result {
        case .unverified(let transaction, let error):
            return (transaction: transaction, verified: false)
        case .verified(let transaction):
            return (transaction: transaction, verified: true)
        }
    }
    
    
    private func updatePurchasedIdentifiers(_ transaction: Transaction) async {
        if transaction.revocationDate == nil {
            await updatePurchasedIdentifiers(transaction.productID, insert: true)
        } else {
            await updatePurchasedIdentifiers(transaction.productID, insert: false)
        }
    }
    
    private func updatePurchasedIdentifiers(_ productId: String, insert: Bool) async {
        guard let product = product(from: productId) else {
            return
        }
        
        if insert {
            if product.type == .consumable {
                
//                if cou
            } else {
                if purchasedProducts.contains(productId) {
                    return
                }
            }
            purchasedProducts.append(productId)
        } else {
            if let index = purchasedProducts.firstIndex(where: {$0 == productId}) {
                purchasedProducts.remove(at: index)
            }
        }
    }
    
}


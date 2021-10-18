//
//  PurchaseHelper.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation
import StoreKit

public class PurchaseXManager: NSObject, ObservableObject {
    
    // MARK: Public Property
    /// Array of products retrieved from AppleStore
    @Published public var products: [Product]?
    
    /// Handle for App Store transactions
    private var transactionListener: Task<Void, Error>? = nil
    
    /// Array of productID
    private var purchasedProducts = [String]()
    
    private var purchaseState: PurchaseXState = .notStarted
    
    public var consumableProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .consumable
        })
    }
    
    public var nonConsumbaleProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .nonRenewable
        })
    }
    
    public var subscriptionProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .autoRenewable
        })
    }
    
    public var nonSubscriptionProducts: [Product]? {
        guard products != nil else {
            return nil
        }
        
        return products?.filter({ product in
            product.type == .nonRenewable
        })
    }
        
    // MARK: - Initialization
    public override init() {
        super.init()
        // Listen for App Store transactions
        transactionListener = handTransaction()
    }

    deinit {
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
            guard purchaseState != .inProgress else {
                throw PurchaseXException.purchaseInProgressException
            }
            
            purchaseState = .inProgress
            
            // Start a purchase transaction
            guard let result = try? await product.purchase() else {
                purchaseState = .failed
                throw PurchaseXException.purchaseException
            }
            
            switch result {
            case .success(let verificationResult):
                let checkResult = checkTransactionVerficationResult(result: verificationResult)
                if !checkResult.verified {
                    purchaseState = .failedVerification
                    throw PurchaseXException.transactionVerificationFailed
                }
                
                let validatedTransaction = checkResult.transaction
                
                await validatedTransaction.finish()
                
//                // Because consumable's transaction are not stored in the receipt, So treat differerntly
//                if validatedTransaction.productType == .consumable {
//
//                }
                purchaseState = .complete
                return (transaction: validatedTransaction, purchaseState: .complete)
            case .userCancelled:
                purchaseState = .cancelled
                return (transaction: nil, purchaseState: .cancelled)
            case .pending:
                purchaseState = .pending
                return (transaction: nil, purchaseState: .pending)
            default:
                purchaseState = .unknown
                return (transaction: nil, purchaseState: .unknown)
            }
        }
    
    public func currentEntitlements() async -> Set<String> {
        var entitledProductIds = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            
            if case .verified(let transaction) = result {
                entitledProductIds.insert(transaction.productID)
            }
        }
        
        return entitledProductIds
    }
    
    // MARK: - extend function interface
    
    /// True if purchased
    /// - Parameter productId: productid
    /// - Returns:true if purchased
    public func isPurchased(productId: String) async throws -> Bool {
        return false
        guard let product  = product(from: productId) else {
            return false
        }

//        if product.type == .consumable {
//
//            return false
//        }
        
//        await Transaction.latest(for: productId)
        
//        await subscription.ise
        
        guard let currentEntitlement = await Transaction.currentEntitlement(for: productId) else {
            return false
        }
        
        let result = checkTransactionVerficationResult(result: currentEntitlement)
        if !result.verified {
            throw PurchaseXException.transactionVerificationFailed
        }
        
        return result.transaction.revocationDate == nil && !result.transaction.isUpgraded
    }
    
    /// Product associated with productId
    public func product(from productId: String) -> Product? {
        guard hasProducts() else {
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
    
    /// True if appstore products have been retrived via function
    public func hasProducts() -> Bool {
        guard products != nil else {
            return false
        }

        return products!.count > 0 ? true : false
    }
    
    public func activeSubscriptions(onlyRenewable: Bool = true) async -> [String] {
        
        var productId = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .autoRenewable || (!onlyRenewable && transaction.productType ==  .nonRenewable){
                    productId.insert(transaction.productID)
                }
            }
        }
        return Array(productId)
    }
    
    public func purchasedNonConsumable() async -> [String] {
        var productId = Set<String>()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productType == .nonConsumable {
                    productId.insert(transaction.productID)
                }
            }
        }
        return Array(productId)
    }
    
    public func restorePurchase() async throws {
        try await AppStore.sync()
    }
    
    public func showManageSubscriptions(in scene: UIWindowScene) async throws {
        try await AppStore.showManageSubscriptions(in: scene)
    }
    
    public func beginRefundProcess(from productId: String, in scene: UIWindowScene) async throws -> Bool{
        
        let result = await Transaction.latest(for: productId)
        
        switch result{
        case .verified(let transaction):
            do {
                let status = try await transaction.beginRefundRequest(in: scene)
                switch status{
                case .success:
                    return true
                case .userCancelled:
                    return false
                @unknown default:
                    return false
                }
            } catch {
                throw error
                return false
            }
        case .unverified(let transaction, let error):
                throw(error)
                return false
        case .none:
            return false
        }
    }
    
    private func handTransaction() -> Task<Void, Error> {

            return Task.detached{
                for await verificationResult in Transaction.updates {
                    
                    let checkResult = self.checkTransactionVerficationResult(result: verificationResult)
                    
                    if checkResult.verified {
                        let validatedTransaction = checkResult.transaction
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
        
}

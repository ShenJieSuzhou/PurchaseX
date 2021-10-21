//
//  PXDataPersistence.swift
//  PurchaseX
//
//  Created by shenjie on 2021/10/20.
//

import Foundation
import Security

/// We should  store consumables in keychain becase their transaction are NOT  stored in the receipt。
public struct PXDataPersistence {
    
    /// Add a consumable productId to keychain, and set the count  value to 1.
    /// - Parameter productId: productid
    /// - Returns: True if insert successfully
    public static func purchase(productId: String) -> Bool {
        if hasPurchased(productId: productId) {
            return true
        }
        
        // Create a query for what we want to add to keychain
        let query = [kSecClass as String : kSecClassGenericPassword,
                                     kSecAttrAccount as String : productId,
                                     kSecValueData as String : "1".data(using: .utf8)!] as CFDictionary
        // Add the item to keychain
        let status = SecItemAdd(query, nil)
        return status == errSecSuccess
    }
    
    
    /// True if purchased
    /// - Parameter productId: productID
    /// - Returns: True if purchased
    public static func hasPurchased(productId: String) -> Bool {
        // Create a query
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecAttrAccount as String : productId,
                     kSecMatchLimit as String : kSecMatchLimitOne] as CFDictionary
        
        // Search for the item in the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        return status == errSecSuccess
    }
    
    
    /// Update the count num associated with consumable 'productId' in the keychain
    /// - Parameter productId: The consumable productId
    /// - Returns: True if the update successfully
    public static func update(productId: String) -> Bool {
        var count = getProductCount(productId: productId)
        if count < 0 {
            count = 0
        }
        
        // Create a query
        let query = [kSecClass as String : kSecClassGenericPassword,
                                     kSecAttrAccount as String : productId,
                                     kSecValueData as String : String(count).data(using: .utf8)!] as CFDictionary
        let value = count + 1
        let newQuery = [kSecAttrAccount as String : productId,
                        kSecValueData as String : String(value).data(using: .utf8)!] as CFDictionary
        // Update item
        let status = SecItemUpdate(query, newQuery)
        return status == errSecSuccess
    }
    
    
    /// Get the count value associated with a consumable productId
    /// - Parameter productId: productId
    /// - Returns: The amount of the cnsumable product. Return 0 if NOT found.
    public static func getProductCount(productId: String) -> Int {
        // Create a query
        let query  = [kSecClass as String : kSecClassGenericPassword,
                      kSecAttrAccount as String : productId,
                      kSecMatchLimit as String : kSecMatchLimitOne,
                      kSecReturnAttributes as String : true,
                      kSecReturnData as String : true] as CFDictionary
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard status == errSecSuccess else {
            return 0
        }
        
        // Extract the count value data
        guard let foundItem = item as? [String : Any],
              let countData = foundItem[kSecValueData as String] as? Data,
              let countValue = String(data: countData, encoding: .utf8)
        else {
            return 0
        }
        return Int(countValue) ?? 0
    }
    
    
    /// Remove all consumable records in the keychain
    /// - Parameter productIds: a array of consumable product
    /// - Returns: True if reset successfully
    public static func resetAllConsumable(productIds: Set<String>) -> Bool{
        var flag: Bool = true
        let query = [kSecClass as String : kSecClassGenericPassword,
                     kSecMatchLimit as String: kSecMatchLimitAll,
                     kSecReturnAttributes as String: true,
                     kSecReturnData as String: true] as CFDictionary
        
        // Search for all the items created by this app in the keychain
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query, &item)
        guard status == errSecSuccess else { return false}
        
        guard let entries = item as? [[String : Any]] else { return false }
        
        for entry in entries {
            if  let pid = entry[kSecAttrAccount as String] as? String,
                productIds.contains(pid),
                let data = entry[kSecValueData as String] as? Data,
                let sValue = String(data: data, encoding: String.Encoding.utf8) {
                // Create a query of what we want to search for
                let query = [kSecClass as String : kSecClassGenericPassword,
                             kSecAttrAccount as String : pid,
                             kSecValueData as String: sValue,
                             kSecMatchLimit as String: kSecMatchLimitOne] as CFDictionary
                
                // Search for the item in the keychain
                let status = SecItemDelete(query)
                if status != errSecSuccess {
                    flag = false
                    break
                }
            }
        }
        
        return flag
    }
}

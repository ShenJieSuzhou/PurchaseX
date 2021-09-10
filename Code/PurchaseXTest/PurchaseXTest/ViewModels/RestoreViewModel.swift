//
//  RestoreViewModel.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/8/12.
//

import Foundation
import PurchaseX
import SwiftUI

struct RestoreViewModel {
    
    @ObservedObject var purchaseXManager: PurchaseXManager
    @Binding var restored: Bool
    @Binding var isLoading: Bool
    
    func restorePurchase() {
        
//        purchaseXManager.restorePurchase { notification in
//            switch notification{
//            case .purchaseRestoreSuccess:
//                print("Restore Success")
//            case .purchaseRestoreFailure:
//                print("Restore Failed")
//            default:
//                break
//            }
//        }
        
        purchaseXManager.restorePurchase { notification in
            
            switch notification{
            case .purchaseRestoreSuccess:
                updatePurchaseState(state: .complete)
                // validate receipt
                let _ = purchaseXManager.validateReceiptLocally { validateResult in
                    switch validateResult {
                    case .success(let receipt):
                        print("")
                    case .error(let error):
                        print("")
                    }
                }
                
            case .purchaseRestoreFailure:
                updatePurchaseState(state: .failed)
            default:
                break
            }
        }
    }
        
    private func updatePurchaseState(state: PurchaseXState) {
        isLoading = false
        restored = state == .complete
    }
}

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
    
    
    func restorePurchase() {
        purchaseXManager.restorePurchase { notification in
            
            switch notification{
            case .purchaseRestoreSuccess:
                fallthrough
            case .purchaseRestoreFailure:
                
            default:
                break
            }
        }
    }
}

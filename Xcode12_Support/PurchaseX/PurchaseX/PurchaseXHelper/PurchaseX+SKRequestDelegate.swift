//
//  PurchaseX+SKRequestDelegate.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/9.
//

import Foundation
import StoreKit

extension PurchaseXManager: SKRequestDelegate {

    public func requestDidFinish(_ request: SKRequest) {

        if productsRequest != nil {
            productsRequest = nil
            PXLog.event(.requestProductsDidFinish)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsDidFinish)
            }
            return
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        if productsRequest != nil {
            productsRequest = nil
            PXLog.event(.requestProductsFailure)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsFailure)
            }
            return
        }
    }
}


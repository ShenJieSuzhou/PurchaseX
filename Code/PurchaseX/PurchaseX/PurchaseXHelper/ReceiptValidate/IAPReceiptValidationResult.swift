//
//  IAPReceiptValidationResult.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/27.
//

import Foundation

public enum ReceiptValidationResult {
    case success(receipt: Receipt?)
    case error(error: Error?)
}

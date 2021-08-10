//
//  PurchaseState.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation
import SwiftUI

public enum PurchaseXState {
    case notStarted
    case inProgress
    case complete
    case pending
    case cancelled
    case failed
    case failedVerification
    case unknown
}

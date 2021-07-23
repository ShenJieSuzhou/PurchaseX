//
//  PXLog.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/23.
//

import Foundation
import os.log

/// we use Apple's unified logging system to log errors, notifications and general messages.

public struct PXLog {
    private static let iapLog = OSLog(subsystem: Bundle.main.bundleIdentifier, category: "IAP")
    

    
    
}

//
//  PurchaseXTestApp.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/8/10.
//

import SwiftUI
import PurchaseX

@main
struct PurchaseXTestApp: App {
    
    @StateObject var purchaseXManager = PurchaseXManager()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(PurchaseXManager())
        }
    }
}

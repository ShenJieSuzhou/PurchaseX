//
//  BadgeView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/30.
//

import SwiftUI
import PurchaseX


struct BadgeView: View {
    var purchaseState: PurchaseXState
    
    var body: some View {
        
        if let options = badgeOptions() {
            
            Image(systemName: options.badgeName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25, alignment: .center)
                .foregroundColor(options.fgColor)
        }
    }
    
    
    func badgeOptions() -> (badgeName: String, fgColor: Color)? {
        switch purchaseState {
            case .notStarted:         return nil
            case .inProgress:         return (badgeName: "hourglass", Color.gray)
            case .complete:           return (badgeName: "checkmark", Color.green)
            case .pending:            return (badgeName: "hourglass", Color.orange)
            case .cancelled:          return (badgeName: "person.crop.circle.fill.badge.xmark", Color.blue)
            case .failed:             return (badgeName: "hand.raised.slash", Color.red)
            case .failedVerification: return (badgeName: "hand.thumbsdown.fill", Color.red)
            case .unknown:            return nil
        }
    }
}

//
//  PurchaseErrorView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/22.
//

import SwiftUI

struct PurchaseErrorView: View {
    var body: some View {
        Text("Store Error")
            .font(.title2)
            .foregroundColor(.white)
            .padding()
            .frame(height: 40)
            .background(Color.red)
            .cornerRadius(25)
    }
}

struct PurchaseErrorView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseErrorView()
    }
}

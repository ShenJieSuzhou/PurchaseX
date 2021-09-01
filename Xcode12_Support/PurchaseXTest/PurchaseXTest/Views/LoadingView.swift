//
//  LoadingView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/9/1.
//

import SwiftUI

struct LoadingView: View {
    @Binding var isLoading: Bool
    var body: some View {
        Group {
            ZStack{
                if isLoading {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    ProgressView("Please wait")
                }
            }
        }
    }
}

//struct LoadingView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoadingView(isLoading: true)
//    }
//}

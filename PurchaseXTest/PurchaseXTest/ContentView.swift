//
//  ContentView.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Producst")) {

                }

                Section(header: Text("VIP Services")) {

                }

                Section(header: Text("Subscriptions")) {

                }
            }.listStyle(.insetGrouped)
            .navigationTitle("PurchaseX")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
                                                               
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
                .previewInterfaceOrientation(.portraitUpsideDown)
        } else {
            // Fallback on earlier versions
        }
    }
}

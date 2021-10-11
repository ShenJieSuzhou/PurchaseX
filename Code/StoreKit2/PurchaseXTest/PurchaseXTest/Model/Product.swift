//
//  Product.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/21.
//

import Foundation
import SwiftUI

struct PXProduct{

    public var productID: String
    public var productName: String
    public var price: String
    public var image: String
    
    
    init(pid: String, displayName pName: String, thumb pImage: String, price pPrice: String) {
        self.productID = pid
        self.productName = pName
        self.price = pPrice
        self.image = pImage
    }
    
}

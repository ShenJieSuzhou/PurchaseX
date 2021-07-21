//
//  Product.swift
//  PurchaseXTest
//
//  Created by shenjie on 2021/7/21.
//

import Foundation
import SwiftUI

enum ProductType {
    case Non_Consumable                 /// 非消耗性
    case Consumable                     /// 消耗性
    case Auto_Renewable_Subscriptions   /// 自动续期订阅
    case Non_Renewing_Subscriptions     /// 非续期订阅
}


protocol ProductProtocol {
    var type: ProductType { get }
}


struct Product{
    
    private var productID: String
    private var productName: String
    private var price: String
    private var image: Image
    
    
    init(pid: String, displayName pName: String, thumb pImage: String, price pPrice: String) {
        self.productID = pid
        self.productName = pName
        self.price = pPrice
        self.image = Image(pImage)
    }
    
}

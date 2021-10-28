# PurchaseX

## Update log:

目前已支持 StoreKit2 🎉🎉🎉🎉;

**PurchaseX** 是基于 Swift 语言开发，专门用于给您的应用或者游戏提供应用内购买（In-App_purchase）解决方案的轻量级 Framework；

**PurchaseX** 能让开发者轻松的为应用程序集成苹果的应用内购买，目前最低支持 iOS 8.0 版本；
z
## 特性：
1. 所有的接口回调都是基于闭包实现，超级简单方便
2. 支持购买消耗品和非消耗品
3. 支持 restore 恢复购买
4. 支持自动订阅和非自动续订商品
5. 支持 Receipt 本地验证
6. 支持 Receipt App Store 远程验证
7. 支持获取 Receipt Model 信息

## 文档：

1. 初始化：


```swift
var purchaseXManager = PurchaseXManager()
```


2.请求商品信息


```swift
purchaseXManager.requestProductsFromAppstore { notification in
            if notification == .requestProductsStarted {
            	print("Request Products Started")
            } else if notification == .requestProductsSuccess {
                print("Request Products Success")
            } else if notification == .requestProductsFailure {
                print("Request Products Failed")
            } else if notification == .requestProductsDidFinish {
                print("Request Products Finished")
            } else if notification == .requestProductsNoProduct {
                print("No Products")
            } else if notification == .requestProductsInvalidProducts {
                print("Invalid Products")
            }
        }
```


3. 购买商品


```swift
purchaseXManager.purchase(product: purchaseXManager.product(from: product.productID)!) { notification in
            if notification == .purchaseSuccess{
                print("Purchase Success")
            } else if notification == .purchaseCancelled {
                print("Purchase Cancelled")
            } else if notification == .purchaseFailure {
                print("Purchase Failed")
            } else if notification == .purchaseAbort {
                print("Purchase Abort")
            } else if notification == .purchasePending {
                print("Purchase Pending")
            }
        }
```


4. 恢复购买


```swift
purchaseXManager.restorePurchase { notification in
            switch notification{
            case .purchaseRestoreSuccess:
                print("Restore Success")
            case .purchaseRestoreFailure:
                print("Restore Failed")
            default:
                break
            }
        }
```


5. 验证票据


```swift
/// validate locally
                purchaseXManager.validateReceiptLocally { validateResult in
                    switch validateResult {
                    case .success(let receipt):
                        print("receipt:\(receipt)")
                    case .error(let error):
                        print("Validate Failed:\(error)")
                    }
                }
```



```swift
/// validate remotelly
purchaseXManager.validateReceiptRemotely(shareSecret: "put your share secret key", isSandBox: true) { validateResult in
                    switch validateResult {
                    case .success(let receipt):
                        print("receipt:\(receipt)")
                    case .error(let error):
                        print("Validate Failed:\(error)")
                    }
                }
```
6. 未完待续


## 联系方式：

### 微信公众号

![image](https://github.com/ShenJieSuzhou/PurchaseX/blob/main/ContactMe/QR.png)

### 邮箱

745689122@qq.com



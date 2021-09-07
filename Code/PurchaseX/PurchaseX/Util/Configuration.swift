//
//  ConfigManager.swift
//  PurchaseX
//
//  Created by shenjie on 2021/7/22.
//

import Foundation

public struct Configuration {
    
    public static let ConfigFile = "Products"
    
    /// read plist file to get products info
    public static func readConfigFile() -> Set<String>? {
        
        guard let result = Configuration.readPropertyFile(filename: ConfigFile) else {
            PXLog.event(.configurationNotFound)
            PXLog.event(.configurationFailure)
            return nil
        }
        
        guard result.count > 0 else {
            PXLog.event(.configurationEmpty)
            PXLog.event(.configurationFailure)
            return nil
        }
        
        guard let values = result[ConfigFile] as? [String] else {
            PXLog.event(.configurationEmpty)
            PXLog.event(.configurationFailure)
            return nil
        }
        PXLog.event(.configurationSuccess)
        return Set<String>(values.compactMap { $0 } )
    }
    
    /// Read plist file and return a dictionary of values
    private static func readPropertyFile(filename: String) -> [String : AnyObject]? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            if let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject] {
                return contents
            }
        }
        
        return nil // [:]
    }
}

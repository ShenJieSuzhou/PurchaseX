//
//  File.swift
//  PurchaseX
//
//  Created by shejie on 2021/9/5.
//

import Foundation

extension DateFormatter {
    /** Date formatter code from [objc.io tutorial](https://www.objc.io/issues/17-security/receipt-validation/#parsing-the-receipt)*/
    static let appleValidator: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}

extension TimeInterval {
    /** Use to convert TimeInterval to seconds*/
    private struct Constants {
        static let thousand: Double = 1000
    }
    
    init?(millisecondsString: String) {
        guard let milliseconds = TimeInterval(millisecondsString) else {
            return nil
        }
        self = milliseconds / Constants.thousand
    }
}

extension JSONDecoder {
    static let receiptDecoder: JSONDecoder = {
       let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let seconds = TimeInterval(millisecondsString: dateString) {
                return Date(timeIntervalSince1970: seconds)
            }
            
            if let formattedDate = DateFormatter.appleValidator.date(from: dateString) {
                return formattedDate
            }
            
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Cannot decode date string \(dateString)")
        })

    return decoder
    }()
}

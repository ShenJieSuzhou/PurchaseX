//
//  IAPOpenSSL.swift
//  PurchaseX
//
//  Created by shenjie on 2021/8/5.
//

import Foundation

/// Helper functions used when working with OpenSSL and the App Store ASN.1 receipt payload.
public struct IAPOpenSSL {
    
    /// Get an Int value from the ASN.1 receipt payload.
    /// - Parameters:
    ///   - p:              Pointer to the location of the integer in the ASN.1 data.
    ///   - expectedLength: The expected length of the integer.
    /// - Returns:          Returns an Int value, or nil if the integer value couldn't be read.
    public static func asn1Int(p: inout UnsafePointer<UInt8>?, expectedLength: Int) -> Int? {
        var tag: Int32          = 0
        var asn1Class: Int32    = 0
        var length: Int         = 0
        var value: Int?         = nil
        
        ASN1_get_object(&p, &length, &tag, &asn1Class, expectedLength)
        guard tag == V_ASN1_INTEGER else { return value }
        guard let intObject = c2i_ASN1_INTEGER(nil, &p, length) else { return value }

        value = ASN1_INTEGER_get(intObject)
        ASN1_INTEGER_free(intObject)
        
        return value
    }
    
    /// Get a String value from the ASN.1 receipt payload.
    /// - Parameters:
    ///   - p:              Pointer to the location of the String in the ASN.1 data.
    ///   - expectedLength: The expected length of the String.
    /// - Returns:          Returns a String value, or nil if the String couldn't be read.
    public static func asn1String(p: inout UnsafePointer<UInt8>?, expectedLength: Int) -> String? {
        var tag: Int32                  = 0
        var asn1Class: Int32            = 0
        var length: Int                 = 0
        var p2s: UnsafePointer<UInt8>?  = p
        
        ASN1_get_object(&p2s, &length, &tag, &asn1Class, expectedLength)
        
        switch tag {
            case V_ASN1_UTF8STRING: return String(bytesNoCopy: UnsafeMutableRawPointer(mutating: p2s!), length: length, encoding: .utf8, freeWhenDone: false)
            case V_ASN1_IA5STRING: return String(bytesNoCopy: UnsafeMutablePointer(mutating: p2s!), length: length, encoding: .ascii, freeWhenDone: false)
            default: return nil
        }
    }
    
    /// Get a Data value from the ASN.1 receipt payload.
    /// - Parameters:
    ///   - p:              Pointer to the location of the Data in the ASN.1 data.
    ///   - expectedLength: The expected length of the data.
    /// - Returns:          Returns a Data value, or nil if the data couldn't be read.
    public static func asn1Data(p: UnsafePointer<UInt8>, expectedLength: Int) -> Data {
        Data(bytes: p, count: expectedLength)
    }
    
    /// Get a Date value from the ASN.1 receipt payload.
    /// - Parameters:
    ///   - p:              Pointer to the location of the Date in the ASN.1 data.
    ///   - expectedLength: The expected length of the date.
    /// - Returns:          Returns a Date, or nil if the value couldn't be read.
    public static func asn1Date(p: inout UnsafePointer<UInt8>?, expectedLength: Int) -> Date? {
        var tag: Int32                  = 0
        var asn1Class: Int32            = 0
        var length: Int                 = 0
        var p2s: UnsafePointer<UInt8>?  = p

        ASN1_get_object(&p2s, &length, &tag, &asn1Class, expectedLength)
        
        guard tag == V_ASN1_IA5STRING else { return nil }
        guard let date = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: p2s!), length: length, encoding: .ascii, freeWhenDone: false) else { return nil }
        
        // The date should be in a fixed RFC3339 format that requires the use of the en_US_POSIX locale.
        // See https://developer.apple.com/documentation/foundation/dateformatter
        let rfc3339Formatter = DateFormatter()
        rfc3339Formatter.locale = Locale(identifier: "en_US_POSIX")
        rfc3339Formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        rfc3339Formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return rfc3339Formatter.date(from: date)
    }
}

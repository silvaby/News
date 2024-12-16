//
//  String.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import CryptoKit
import Foundation

extension String {
    
    func hashString() -> String {
        let hashed = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }
    
    func toDate(format: String = "E, dd MMM yyyy HH:mm:ss Z") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = format
        
        return dateFormatter.date(from: self)
    }
    
}

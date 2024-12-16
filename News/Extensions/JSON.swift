//
//  JSON.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

extension JSON {
    
    var urlQuery: String {
        var parameters = [String]()
        
        for (key, value) in self {
            if let parameter = "\(key)=\(value)".addingPercentEncoding(withAllowedCharacters: JSON.characterSet) {
                parameters.append(parameter)
            }
        }
        
        return "?\(parameters.joined(separator: "&"))"
    }
    
    private static let characterSet: CharacterSet = {
        var characterSet = CharacterSet.urlPathAllowed
        characterSet.remove("+")
        
        return characterSet
    }()
    
}

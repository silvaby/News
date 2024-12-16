//
//  Codable.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

extension Decodable {
    
    static func objectFromJSON(_ json: JSON,
                               using keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                               dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> Self? {
        if JSONSerialization.isValidJSONObject(json),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            decoder.dateDecodingStrategy = dateDecodingStrategy
            
            do {
                let object = try decoder.decode(Self.self, from: jsonData)
                return object
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
    static func objectsFromJSONArray(_ jsonArray: JSONArray,
                                     using keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
                                     dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) -> [Self]? {
        if JSONSerialization.isValidJSONObject(jsonArray),
           let jsonData = try? JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted) {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = keyDecodingStrategy
            decoder.dateDecodingStrategy = dateDecodingStrategy
            
            do {
                let object = try decoder.decode([Self].self, from: jsonData)
                return object
            } catch {
                return nil
            }
        }
        
        return nil
    }
    
}

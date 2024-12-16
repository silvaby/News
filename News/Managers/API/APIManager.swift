//
//  APIManager.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

class APIManager {
    
    // MARK: - Properties
    private let networkManager = NetworkManager.shared
    
}

// MARK: - Internal methods
internal extension APIManager {
    
    func JSONRequest(url: String,
                     parameters: JSON? = nil,
                     method: HTTPMethod,
                     headers: HTTPHeaders? = nil,
                     timeoutInterval: TimeInterval = 30) async throws -> JSON {
        return try await apiRequest(url: url,
                                    parameters: parameters,
                                    method: method,
                                    headers: headers,
                                    requestContentType: .json,
                                    timeoutInterval: timeoutInterval)
    }
    
    func JSONArrayRequest(url: String,
                          parameters: JSON? = nil,
                          method: HTTPMethod,
                          headers: HTTPHeaders? = nil,
                          timeoutInterval: TimeInterval = 30) async throws -> JSONArray {
        return try await apiRequest(url: url,
                                    parameters: parameters,
                                    method: method,
                                    headers: headers,
                                    requestContentType: .json,
                                    timeoutInterval: timeoutInterval)
    }
    
    func XMLDataRequest(url: String,
                        parameters: JSON? = nil,
                        method: HTTPMethod,
                        headers: HTTPHeaders? = nil,
                        timeoutInterval: TimeInterval = 30) async throws -> Data {
        return try await apiRequest(url: url,
                                    parameters: parameters,
                                    method: method,
                                    headers: headers,
                                    requestContentType: .json,
                                    timeoutInterval: timeoutInterval,
                                    isXML: true)
    }
    
    func apiRequest<T: Any>(url: String,
                            parameters: JSON? = nil,
                            method: HTTPMethod,
                            headers: HTTPHeaders? = nil,
                            requestContentType: RequestContentType = .json,
                            timeoutInterval: TimeInterval = 30,
                            isXML: Bool = false) async throws -> T {
        let headers = httpHeadersWith(predefinedHttpHeaders: headers,
                                      requestContentType: requestContentType)
        
        let result: Any = try await networkManager.networkRequestWith(urlString: url,
                                                                      httpMethod: method,
                                                                      parameters: parameters,
                                                                      headers: headers,
                                                                      timeoutInterval: timeoutInterval,
                                                                      isXML: isXML)
        
        guard let response = result as? T else {
            throw NetworkError(type: .serverBadResponse)
        }
        
        return response
    }
    
}

// MARK: - Parsing methods
extension APIManager {
    
    func parseJSONToEntity<T: Decodable>(json: JSON,
                                         dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> T {
        if let entity = T.objectFromJSON(json,
                                         dateDecodingStrategy: dateDecodingStrategy) {
            return entity
        } else {
            throw NetworkError(type: .applicationJSONSerializationError)
        }
    }
    
    func parseJSONArrayToEntity<T: Decodable>(jsonArray: JSONArray,
                                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate) throws -> [T] {
        if let entity = T.objectsFromJSONArray(jsonArray,
                                               dateDecodingStrategy: dateDecodingStrategy) {
            return entity
        } else {
            throw NetworkError(type: .applicationJSONSerializationError)
        }
        
    }
    
}

// MARK: - Parsing methods
extension APIManager {
    
    func parseXMLToEntity<T, P: Parsable>(data: Data, parser: P) async throws -> T where P.T == T {
        do {
            return try await parser.parse(data: data)
        } catch {
            throw error.networkError
        }
    }
    
}

// MARK: - Private methods
private extension APIManager {
    
    func httpHeadersWith(predefinedHttpHeaders: HTTPHeaders?,
                         requestContentType: RequestContentType?) -> HTTPHeaders {
        var headers = predefinedHttpHeaders ?? [:]
        
        if let requestContentType = requestContentType {
            headers["Content-Type"] = requestContentType.rawValue
        }
        
        return headers
    }
    
}

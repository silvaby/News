//
//  NetworkManager.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

final class NetworkManager {
    
    // MARK: - Properties
    static let shared = NetworkManager()
    private let queryHttpMethods: [HTTPMethod] = [.GET]
    private var urlSession: URLSession!
    
    // MARK: - Init methods
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        urlSession = URLSession(configuration: configuration)
    }
    
}

// MARK: - Open methods
extension NetworkManager {
    
    func networkRequestWith(urlString: String,
                            httpMethod: HTTPMethod,
                            parameters: JSON?,
                            headers: HTTPHeaders?,
                            timeoutInterval: TimeInterval,
                            isXML: Bool) async throws -> Any {
        var urlString = urlString
        var body: Data? = nil
        
        if let parameters = parameters {
            if queryHttpMethods.contains(httpMethod) {
                addGetParametersToURL(&urlString, parameters: parameters)
            } else {
                body = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }
        
        return try await networkRequestWith(urlString: urlString,
                                            httpMethod: httpMethod,
                                            httpBody: body,
                                            headers: headers,
                                            timeoutInterval: timeoutInterval,
                                            isXML: isXML)
    }
    
    func networkRequestWith(urlString: String,
                            httpMethod: HTTPMethod,
                            httpBody: Data?,
                            headers: HTTPHeaders?,
                            timeoutInterval: TimeInterval,
                            isXML: Bool) async throws -> Any {
        guard let url = URL(string: urlString) else {
            throw NetworkError(type: .requestError)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        request.allHTTPHeaderFields = headers
        request.timeoutInterval = timeoutInterval
        
        guard !Task.isCancelled else { throw NetworkError(type: .requestWasCancelled) }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            return try parse(response: response, data: data, isXML: isXML)
        } catch {
            throw error.networkError
        }
    }
    
}

// MARK: - Private methods
private extension NetworkManager {
    
    func addGetParametersToURL(_ url: inout String, parameters: JSON) {
        url += parameters.urlQuery
    }
    
    func parse(response: URLResponse, data: Data, isXML: Bool) throws -> Any {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError(type: .serverBadResponse)
        }
        
        let statusCode = httpResponse.statusCode
        
        if 200..<300 ~= statusCode {
            return isXML ? data : try parseSuccess(data: data)
            
        } else if statusCode == 401 {
            throw NetworkError(code: 401, type: .unauthorized)
            
        } else if statusCode == 404 {
            throw NetworkError(code: 404, type: .resourceNotFound)
            
        } else {
            return try parseFailure(statusCode: statusCode, data: data)
        }
    }
    
    func parseSuccess(data: Data) throws -> Any {
        if let JSONResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
            return JSONResponse
            
        } else if let JSONResponseArray = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONArray {
            return JSONResponseArray
            
        } else if let object = try? JSONSerialization.jsonObject(with: data, options: []) {
            return object
            
        } else if let string = String(data: data, encoding: .utf8) {
            return string
            
        } else {
            return data
        }
    }
    
    func parseFailure(statusCode: Int, data: Data) throws -> Any {
        if let JSONResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON {
            var errorType: NetworkErrorType = .unknown
            
            if let errorMessage = JSONResponse["error_description"] as? String {
                errorType = .error(message: errorMessage)
            }
            
            return NetworkError(code: statusCode, type: errorType, userInfo: JSONResponse)
        } else {
            return NetworkError(code: statusCode, type: .serverBadResponse)
        }
    }
    
}

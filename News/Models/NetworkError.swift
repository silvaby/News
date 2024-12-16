//
//  NetworkError.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import Foundation

enum NetworkErrorType {
    // TODO: - Add more cases to handle a specific error
    case applicationJSONSerializationError
    case serverBadResponse
    case resourceNotFound
    case requestError
    case requestWasCancelled
    case unauthorized
    case unknown
    case error(message: String)
    
    // MARK: - Properties
    var errorDescription: String {
        switch self {
        case .applicationJSONSerializationError:
            return "applicationJSONSerializationError"
        case .serverBadResponse:
            return "serverBadResponse"
        case .resourceNotFound:
            return "resourceNotFound"
        case .requestError:
            return "requestError"
        case .requestWasCancelled:
            return "requestWasCancelled"
        case .unauthorized:
            return "unauthorized"
        case .unknown:
            return "unknown"
        case .error(let message):
            return message
        }
    }
}

struct NetworkError: Error {
    
    // MARK: - Properties
    let code: Int
    let userInfo: JSON?
    let type: NetworkErrorType
    var errorDescription: String { type.errorDescription }
    
    // MARK: - Init
    init(code: Int = -1, type: NetworkErrorType, userInfo: JSON? = nil) {
        self.code = code
        self.type = type
        self.userInfo = userInfo
    }
    
}

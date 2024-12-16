//
//  Error.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//
import Foundation

extension Error {
    
    var networkError: NetworkError {
        if let networkError = self as? NetworkError {
            return networkError
        } else {
            let nsError = self as NSError
            return NetworkError(code: nsError.code,
                                type: networkErrorTypeFrom(nsError: nsError),
                                userInfo: nsError.userInfo)
        }
    }
    
}

private extension Error {
    
    func networkErrorTypeFrom(nsError: NSError) -> NetworkErrorType {
        switch nsError.code {
        default:
            return .error(message: nsError.localizedDescription)
        }
    }
    
}

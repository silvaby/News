//
//  Constants.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//
import UIKit

typealias JSON = [String: Any]
typealias JSONArray = [JSON]
typealias JSONResponse = (Result<JSON, NetworkError>) -> ()
typealias HTTPHeaders = [String: String]

//
//  RequestContentType.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

enum RequestContentType: String {
    case multipart = "multipart/form-data"
    case json = "application/json"
    case xml = "application/xml"
    case urlEncoded = "application/x-www-form-urlencoded"
}

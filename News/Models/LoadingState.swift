//
//  LoadingState.swift
//  News
//
//  Created by Dzmitry on 14.12.24.
//

import SwiftUI

enum LoadingState<T> {
    case initial
    case loading
    case loaded(T)
    case failed(NetworkError)
}

@MainActor
protocol Loadable: Observable {
    associatedtype T
    var loadingState: LoadingState<T> { get }
    func loadData()
}

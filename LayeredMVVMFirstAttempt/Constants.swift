//
//  Constants.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation

enum Constants {
    static let apiKey: String = {
        guard let key = ProcessInfo.processInfo.environment["API_KEY"] else { // ProcessInfo.processInfo.environment ile environment variable’ları okur.
            fatalError("API_KEY not found in Environment Variables")
        }
        return key
    }()

    static let apiHost: String = {
        guard let host = ProcessInfo.processInfo.environment["API_HOST"] else {
            fatalError("API_HOST not found in Environment Variables")
        }
        return host
    }()
}

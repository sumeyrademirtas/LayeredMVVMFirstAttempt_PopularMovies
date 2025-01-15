//
//  PopularMoviesResponse.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/15/25.
//

import Foundation

struct PopularMoviesResponse: Decodable {
    let results: [Movie]
}

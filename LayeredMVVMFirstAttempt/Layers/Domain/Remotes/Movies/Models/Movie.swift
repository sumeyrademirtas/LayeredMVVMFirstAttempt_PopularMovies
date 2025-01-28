//
//  Movie.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/15/25.
//

import Foundation

// MARK: - Movie
struct Movie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String
    let voteAverage: Double
    
    // Tam URL oluşturmak için bir computed property
    var fullPosterURL: String {
        let baseURL = "https://image.tmdb.org/t/p/w500" // Resim için temel URL
        return "\(baseURL)\(posterPath)"
    }

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}

// MARK: - MoviesResponse
struct MoviesResponse: Decodable {
    let results: [Movie]
}

enum MovieCategory: String {
    case nowPlaying = "now_playing"
    case popular = "popular"
    case topRated = "top_rated"
    case upcoming = "upcoming"
    
    static var orderedCategories: [MovieCategory] {
        return [.popular, .upcoming, .nowPlaying, .topRated]
    }
    
    var endpoint: String {
            switch self {
            case .nowPlaying:
                return "/movie/now_playing"
            case .popular:
                return "/movie/popular"
            case .topRated:
                return "/movie/top_rated"
            case .upcoming:
                return "/movie/upcoming"
            }
        }
    
    var displayName: String {
            switch self {
            case .nowPlaying:
                return "Now Playing"
            case .popular:
                return "Popular Movies"
            case .topRated:
                return "Top Rated"
            case .upcoming:
                return "Upcoming"
            }
        }
}

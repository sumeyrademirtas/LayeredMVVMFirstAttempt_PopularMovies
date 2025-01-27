//
//  TmdbApi.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/23/25.
//
import Foundation
import Moya

enum TMDBApi {
//    case getPopularMovies(page: Int)
//    case getTopRatedMovies(page: Int)
//    case getNowPlayingMovies(page: Int)
//    case getUpcomingMovies(page: Int)
    case getMovies(category: MovieCategory, page: Int) // Dinamik olarak kategori ve sayfa alır
}

extension TMDBApi: TargetType {
    private var constants: Constants {
        return Constants()
    }
    
    var baseURL: URL {
        return URL(string: constants.apiHost)! // TMDB API Base URL
    }
    
    var path: String {
        switch self {
        case .getMovies(let category, _):
            return category.endpoint // MovieCategory'deki endpoint'i kullanır
        }
    }
    
    var method: Moya.Method {
        return .get // TMDB genellikle GET istekleri kullanır.
    }
    
    var task: Task {
         switch self {
         case .getMovies(_, let page):
             return .requestParameters(parameters: [
                 "page": page,
                 "api_key": constants.apiKey,
                 "language": "en-US"
             ], encoding: URLEncoding.default)
         }
     }
    
    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    var sampleData: Data {
        return Data() // Test verileri
    }
}

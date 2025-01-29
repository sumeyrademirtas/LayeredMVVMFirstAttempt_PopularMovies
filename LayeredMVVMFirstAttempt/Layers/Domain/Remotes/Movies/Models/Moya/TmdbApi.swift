//
//  TmdbApi.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/23/25.
//
import Foundation
import Moya

enum TMDBApi {
    case getPopularMovies(page: Int)
    case getTopRatedMovies(page: Int)
    case getNowPlayingMovies(page: Int)
    case getUpcomingMovies(page: Int)    
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
        case .getPopularMovies:
            return "/movie/popular"
        case .getTopRatedMovies:
            return "/movie/top_rated"
        case .getNowPlayingMovies:
            return "/movie/now_playing"
        case .getUpcomingMovies:
            return "/movie/upcoming"
        }
    }
    
    var method: Moya.Method {
        return .get // TMDB genellikle GET istekleri kullanır.
    }
    
    var task: Task {

        switch self {
        case .getPopularMovies(page: let page), .getTopRatedMovies(page: let page), .getNowPlayingMovies(page: let page), .getUpcomingMovies(page: let page):
            var params = [String:Any]()
            params["api_key"] = constants.apiKey
            params["page"] = page
            params["language"] = "en-US"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
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

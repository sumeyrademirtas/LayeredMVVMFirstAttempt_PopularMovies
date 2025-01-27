//
//  PopularMoviesBuilder.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/4/25.
//

import UIKit
import Moya

protocol PopularMoviesBuilder {
    func build() -> UIViewController
}



struct PopularMoviesBuilderImplementation: PopularMoviesBuilder {
    func build() -> UIViewController {
        
        let constants = Constants()
        
//        let service = PopularMoviesServiceImplementation(constants: constants)
        let service = TmdbServiceImpl()

        
        let useCase = MoviesUseCaseImplementation(service: service)
        
        let viewModel = MoviesViewModel(useCase: useCase)
                
        let provider = MoviesCollectionViewProviderImpl()
        
        let vc = PopularMoviesViewController(viewModel: viewModel, provider: provider)
        
        return vc
    }
    
    
}

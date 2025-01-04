//
//  PopularMoviesBuilder.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/4/25.
//

import UIKit

protocol PopularMoviesBuilder {
    func build() -> UIViewController
}



struct PopularMoviesBuilderImplementation: PopularMoviesBuilder {
    func build() -> UIViewController {
        
        let service = PopularMoviesServiceImplementation(apiHost: Constants.apiHost, apiKey: Constants.apiKey)
        
        let useCase = PopularMoviesUseCaseImplementation(service: service)
        
        let viewModel = PopularMoviesViewModel()
        viewModel.inject(useCase: useCase)
        
        let vc = PopularMoviesViewController(viewModel: viewModel)
        
        return vc
    }
    
    
}

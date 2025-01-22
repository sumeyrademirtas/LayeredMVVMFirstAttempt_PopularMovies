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
        
        let constants = Constants()
        
        let service = PopularMoviesServiceImplementation(constants: constants)
        
        let useCase = PopularMoviesUseCaseImplementation(service: service)
        
        let viewModel = PopularMoviesViewModel(useCase: useCase)
                
        let provider = PopularMoviesTableViewProviderImpl()
        
        let vc = PopularMoviesViewController(viewModel: viewModel, provider: provider)
        
        return vc
    }
    
    
}

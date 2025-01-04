//
//  PopularMoviesViewModel.swift
//  LayeredMVVMFirstAttempt
//
//  Created by Sümeyra Demirtaş on 1/3/25.
//

import Foundation

import Foundation

final class PopularMoviesViewModel {
    private var useCase: PopularMoviesUseCase? // bunu optional yapmamizin sebebi sonrasinda inject edecegimiz icin.

    func inject(useCase: PopularMoviesUseCase?) { // neden inject? ViewModel in bagimsizliklarini sonradan atamak icin. VM i bagimsiz ve esnek yapiyor.
        self.useCase = useCase
    }

    private(set) var movies: [Movie] = [] // private(set) kullandigimizda bu degiskeni sadece ViewModel degistirebilecek ama disaridan da okunabilir olacak.

    private(set) var errorMessage: String?
}


extension PopularMoviesViewModel {
    func fetchPopularMovies(page: Int, completion: @escaping () -> Void) {
        guard let useCase = useCase else {
            errorMessage = "UseCase is not injected." // eger inject edilmediyse error.
            movies = []
            completion()
            return
        }

        useCase.fetchPopularMovies(page: page) { [weak self] result in // API cagirisi
            guard let self = self else { return }
            switch result {
            case .success(let movies): // basarili ise movies guncellenir ve errormessage bosaltilir.
                self.movies = movies
                self.errorMessage = nil
            case .failure(let error):
                self.movies = [] // hataliysa movies dizisi bos set edilir, errorMessage dolar.
                self.errorMessage = error.localizedDescription
            }
            completion() // islem tamamlandiginda ViewController a haber verir.
        }
    }
}

//
//  ImageLoaderswift.swift
//  Flicker
//
//  Created by Parchuri, Manasa  on 7/12/24.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    func loadImage(from url: URL) {
        print("Starting to load image from URL: \(url)")

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage? in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return UIImage(data: data)
            }
            .catch { error -> Just<UIImage?> in
                print("Error loading image: \(error)")
                return Just(nil)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }

        print("Image loading initiated")
    }

    func cancel() {
        cancellable?.cancel()
    }
}

//
//  ContentView.swift
//  Flicker
//
//  Created by Parchuri, Manasa  on 7/12/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var images: [FlickrImage] = []

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: fetchImages)
                if images.isEmpty {
                    Text("No Images Found")
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                            ForEach(images, id: \.link) { image in
                                if let url = image.media.url {
                                    AsyncImageView(url: url)
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Flickr Image Search")
        }
    }


    struct AsyncImageView: View {
        @StateObject private var loader = ImageLoader()
        let url: URL

        var body: some View {
            ZStack {
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 50, height: 50)  // Ensure the frame is set
            .clipped()
            .onAppear { loader.loadImage(from: url) }
            .onDisappear { loader.cancel() }
        }
    }


    private func fetchImages() {
        let tags = searchText.replacingOccurrences(of: " ", with: ",")
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(tags)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("No data returned or error: \(String(describing: error))")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FlickrResponse.self, from: data)
                DispatchQueue.main.async {
                    self.images = response.items
                    print("Fetched images: \(self.images)")
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

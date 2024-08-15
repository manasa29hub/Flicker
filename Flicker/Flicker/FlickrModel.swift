//
//  FlickrModel.swift
//  Flicker
//
//  Created by Parchuri, Manasa  on 7/12/24.
//

import Foundation

// MARK: - FlickrResponse
struct FlickrResponse: Codable {
    let title: String?
    let link: String?
    let description: String?
    let modified: Date?
    let generator: String?
    let items: [FlickrImage]
    
    enum CodingKeys: String, CodingKey {
        case title, link, description, modified, generator, items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        generator = try container.decodeIfPresent(String.self, forKey: .generator)
        items = try container.decode([FlickrImage].self, forKey: .items)
        
        let modifiedString = try container.decodeIfPresent(String.self, forKey: .modified)
        if let modifiedString = modifiedString {
            modified = DateFormatter.flickrModifiedDateFormatter.date(from: modifiedString)
        } else {
            modified = nil
        }
    }
}

// MARK: - FlickrImage
struct FlickrImage: Codable, Identifiable {
    var id: UUID {
        return UUID()
    }
    let title: String?
    let link: String?
    let media: Media
    let dateTaken: Date?
    let description: String?
    let published: Date?
    let author, authorID, tags: String
    
    enum CodingKeys: String, CodingKey {
        case title, link, media
        case dateTaken = "date_taken"
        case description, published, author
        case authorID = "author_id"
        case tags
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        media = try container.decode(Media.self, forKey: .media)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        author = try container.decode(String.self, forKey: .author)
        authorID = try container.decode(String.self, forKey: .authorID)
        tags = try container.decode(String.self, forKey: .tags)
        
        let dateTakenString = try container.decodeIfPresent(String.self, forKey: .dateTaken)
        if let dateTakenString = dateTakenString {
            dateTaken = DateFormatter.flickrAPIDateFormatter.date(from: dateTakenString)
        } else {
            dateTaken = nil
        }
        
        let publishedString = try container.decodeIfPresent(String.self, forKey: .published)
        if let publishedString = publishedString {
            published = DateFormatter.flickrAPIDateFormatter.date(from: publishedString)
        } else {
            published = nil
        }
    }
}

struct Media: Codable {
        let m: String
        
        var url: URL? {
            return URL(string: m)
        }
    }


extension DateFormatter {
    static let flickrAPIDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
    
    static let flickrModifiedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()
}


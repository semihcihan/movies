//
//  Movie.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

struct Movie: Decodable, Identifiable, Equatable, Hashable {
    let adult: Bool
    let id: Int
    let popularity: Double
    let backdropPath: String?
    let genreIds: [Int]
    let originalLanguage: String
    let overview: String
    let posterPath: String?
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    let title: String
    let originalTitle: String
    let releaseDate: String
}

struct TV: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let popularity: Double
    let backdropPath: String?
    let genreIds: [Int]
    let originalLanguage: String
    let overview: String
    let posterPath: String?
    let voteAverage: Double
    let voteCount: Int
    let name: String
    let originalName: String
    let firstAirDate: String
    let adult: Bool?
}

struct Person: Decodable, Identifiable, Equatable, Hashable {
    let adult: Bool
    let id: Int
    let popularity: Double
    let profilePath: String?
    let name: String
}

enum Media {
    case movie(Movie)
    case tv(TV)
    case person(Person)
    
    var id: Int {
        switch self {
            case .movie(let movie):
                return movie.id
            case .tv(let tv):
                return tv.id
            case .person(let person):
                return person.id
        }
    }
    
    enum MediaType: String, Decodable {
        case movie
        case tv
        case person
    }
}

extension Media {
    var voteAverage: String? {
        var voteAve: Double!
        switch self {
            case .movie(let movie):
                voteAve = movie.voteAverage
            case .tv(let tv):
                voteAve = tv.voteAverage
            case .person(_):
                return nil
        }
        
        return String(voteAve.formatted(.number.precision(.fractionLength(1))))
    }
}

extension Media: Decodable, Hashable {
    init(from decoder: Decoder) throws {
        if let v = try? Movie(from: decoder) {
            self = .movie(v)
        } else if let v = try? TV(from: decoder) {
            self = .tv(v)
        } else if let v = try? Person(from: decoder) {
            self = .person(v)
        } else {
            fatalError()
        }
    }
}

extension Person {
    static var preview: Person = Person(adult: false, id: 500, popularity: 55.852, profilePath: "/yUsSJ0vO8AM9HnDQWuGKMSzCKOP.jpg", name: "Tom Cruise")
}

extension Media {
    var displayedName: String {
        switch self {
            case .movie(let movie):
                return movie.title
            case .tv(let tv):
                return tv.name
            case .person(let person):
                return person.name
        }
    }
    
    var overview: String? {
        switch self {
            case .movie(let movie):
                return movie.overview
            case .tv(let tv):
                return tv.overview
            default:
                return nil
        }
    }
}

enum MovieImageSize {
    enum BackdropSize: String {
        case w300
        case w780
        case w1280
        case original
    }
    
    enum PosterSize: String {
        case w92
        case w154
        case w185
        case w342
        case w500
        case w780
        case original
    }
    
    enum ProfileSize: String {
        case w45
        case w185
        case h632
        case original
    }
}

struct ImagePath {
    private static let baseUrl = "https://image.tmdb.org/t/p/"

    static func path(path: String, size: String) -> String {
        return baseUrl + "/" + size + "/" + path
    }
}

extension Movie {
    static let preview: Movie = Movie(
        adult: false,
        id: 389538,
        popularity: 0.6,
        backdropPath: "/jetHCwCGqNt3e7jYVUwtjgcCyDn.jpg",
        genreIds: [1, 2, 3, 4, 5],
        originalLanguage: "en",
        overview: "Tom Ballard lives with his father James in a campsite in the Dolomites. Tom's mother, Alison Hargreaves died descending K2 when he was just 6 years old. Despite this, he never wanted to be anywhere other than in the mountains. His whole life is dedicated to climbing and his last goal is to solo the Six North Faces of the Alps in a single winter season. Nobody has achieved this before, and he wants to be the first. In a white van driven by James, Tom will travel through the Alps to make his dream come true.",
        posterPath: "/ahofH2q9gBjgGA5MRTl8c4AY05A.jpg",
        video: false,
        voteAverage: 10.0,
        voteCount: 1,
        title: "Tom",
        originalTitle: "Tom",
        releaseDate: "2015-03-25"
    )
}

extension TV {
    static let preview: TV = TV(
        id: 72879,
        popularity: 600.335,
        backdropPath: "/9TXcHOeCsM8W3ZKKIKjdYUsRSeq.jpg",
        genreIds: [1, 2, 3, 4, 5],
        originalLanguage: "en",
        overview: "The story revolves around the people of Sète, France. Their lives are punctuated by family rivalries, romance and scenes from daily life, but also by plots involving police investigations, secrets and betrayals.",
        posterPath: "/3uU5uJzOX7xe7mn7YKpBM9oiEZO.jpg",
        voteAverage: 6.7,
        voteCount: 14,
        name: "Tom",
        originalName: "Tom",
        firstAirDate: "2017-07-17",
        adult: false
    )
}

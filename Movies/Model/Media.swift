//
//  Movie.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

class Medias: Identifiable, Equatable, Decodable, Hashable {
    static func == (lhs: Medias, rhs: Medias) -> Bool {
        lhs.id == rhs.id
    }
        
    var id: Int
    var adult: Bool?
    var popularity: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(id: Int, adult: Bool?, popularity: Double) {
        self.id = id
        self.adult = adult
        self.popularity = popularity
    }
}

class MovieTv: Medias {
    var backdropPath: String
    var genreIds: [Int]
    var originalLanguage: String
    var overview: String
    var posterPath: String
    var voteAverage: Double
    var voteCount: Int
    
    
    init(adult: Bool?, id: Int, popularity: Double, backdropPath: String, genreIds: [Int], originalLanguage: String, overview: String, posterPath: String, voteAverage: Double, voteCount: Int) {
        self.backdropPath = backdropPath
        self.genreIds = genreIds
        self.originalLanguage = originalLanguage
        self.overview = overview
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        
        super.init(id: id, adult: adult, popularity: popularity)
    }
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path", genreIds = "genre_ids", originalLanguage = "original_language", overview, posterPath = "poster_path", voteAverage = "vote_average", voteCount = "vote_count"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        backdropPath = try container.decode(String.self, forKey: .backdropPath)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decode(String.self, forKey: .posterPath)
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
                
        try super.init(from: decoder)
    }
    
//    enum CodingKeys: CodingKey {
//        case adult
//        case id
//        case popularity
//        case backdropPath
//        case genreIds
//        case originalLanguage
//        case overview
//        case posterPath
//        case video
//        case voteAverage
//        case voteCount
//    }
//
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.adult = try container.decode(Bool.self, forKey: .adult)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.popularity = try container.decode(Double.self, forKey: .popularity)
//        self.backdropPath = try container.decode(String.self, forKey: .backdropPath)
//        self.genreIds = try container.decode([Int].self, forKey: .genreIds)
//        self.originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
//        self.overview = try container.decode(String.self, forKey: .overview)
//        self.posterPath = try container.decode(String.self, forKey: .posterPath)
//        self.video = try container.decode(Bool.self, forKey: .video)
//        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
//        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
//    }
}

class Movie: MovieTv {
    var title: String
    var originalTitle: String
    var releaseDate: String
    var video: Bool

    init(adult: Bool?, id: Int, popularity: Double, backdropPath: String, genreIds: [Int], originalLanguage: String, overview: String, posterPath: String, voteAverage: Double, voteCount: Int, title: String, originalTitle: String, releaseDate: String, video: Bool) {
        self.title = title
        self.originalTitle = originalTitle
        self.releaseDate = releaseDate
        self.video = video
        
        super.init(adult: adult, id: id, popularity: popularity, backdropPath: backdropPath, genreIds: genreIds, originalLanguage: originalLanguage, overview: overview, posterPath: posterPath, voteAverage: voteAverage, voteCount: voteCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, originalTitle = "original_title", releaseDate = "release_date", video
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        originalTitle = try container.decode(String.self, forKey: .title)
        releaseDate = try container.decode(String.self, forKey: .title)
        video = try container.decode(Bool.self, forKey: .video)

        try super.init(from: decoder)
    }
}

class TV: MovieTv {
    var name: String
    var originalName: String
    var firstAirDate: String
    
    init(adult: Bool?, id: Int, popularity: Double, backdropPath: String, genreIds: [Int], originalLanguage: String, overview: String, posterPath: String, voteAverage: Double, voteCount: Int, name: String, originalName: String, firstAirDate: String) {
        self.name = name
        self.originalName = originalName
        self.firstAirDate = firstAirDate
        super.init(adult: adult, id: id, popularity: popularity, backdropPath: backdropPath, genreIds: genreIds, originalLanguage: originalLanguage, overview: overview, posterPath: posterPath, voteAverage: voteAverage, voteCount: voteCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case name, originalName = "original_name", firstAirDate = "first_air_date"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        originalName = try container.decode(String.self, forKey: .originalName)
        firstAirDate = try container.decode(String.self, forKey: .firstAirDate)
        
        try super.init(from: decoder)
    }
}

class Person: Medias {
    var profilePath: String
    var name: String

    init(profilePath: String, name: String, adult: Bool?, id: Int, popularity: Double) {
        self.profilePath = profilePath
        self.name = name
        super.init(id: id, adult: adult, popularity: popularity)
    }
    
    enum CodingKeys: String, CodingKey {
        case profilePath = "profile_path", name
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profilePath = try container.decode(String.self, forKey: .profilePath)
        name = try container.decode(String.self, forKey: .name)
                
        try super.init(from: decoder)
    }
}

struct Media: Decodable, Identifiable, Equatable, Hashable {
    let adult: Bool
    let id: Int
    let popularity: Double
    var mediaType: MediaType?
    
    let backdropPath: String?
    let genreIds: [Int]?
    let originalLanguage: String?
    let overview: String?
    let posterPath: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?
    
    let profilePath: String?
    
    let title: String?
    let originalTitle: String?
    let releaseDate: String?

    let name: String?
    let originalName: String?
    let firstAirDate: String?
    
    var displayedTitle: String? {
        title ?? name
    }
    
    var displayedDate: String? {
        releaseDate ?? firstAirDate
    }
    
    var displayedOriginalName: String? {
        originalTitle ?? originalName
    }
    
    enum MediaType: String, Decodable {
        case movie
        case tv
        case person
    }
}

extension Media {    
    static var preview: Media = Media(
        adult: false,
        id: 1,
        popularity: 48.261451,
        mediaType: MediaType.movie,
        backdropPath: "/ndlQ2Cuc3cjTL7lTynw6I4boP4S.jpg",
        genreIds: [
            14,
            28,
            80
        ],
        originalLanguage: "en",
        overview: "From DC Comics comes the Suicide Squad, an antihero team of incarcerated supervillains who act as deniable assets for the United States government, undertaking high-risk black ops missions in exchange for commuted prison sentences.",
        posterPath: "/e1mjopzAS2KNsvpbpahQ1a6SkSn.jpg",
        video: false,
        voteAverage: 5.12,
        voteCount: 1466,
        profilePath: "",
        title: "Suicide Squad",
        originalTitle: "Suicide Squad",
        releaseDate: "2016-08-03",
        name: "",
        originalName: "",
        firstAirDate: ""
    )
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

//enum Genre: Int, String) {
//    case Action = (28, "Action")
//    case Adventure = 12
//    case Animation = 16
//    case
//    {
//        "genres": [
//            {
//                "id": 28,
//                "name": "Action"
//            },
//            {
//                "id": 12,
//                "name": "Adventure"
//            },
//            {
//                "id": 16,
//                "name": "Animation"
//            },
//            {
//                "id": 35,
//                "name": "Comedy"
//            },
//            {
//                "id": 80,
//                "name": "Crime"
//            },
//            {
//                "id": 99,
//                "name": "Documentary"
//            },
//            {
//                "id": 18,
//                "name": "Drama"
//            },
//            {
//                "id": 10751,
//                "name": "Family"
//            },
//            {
//                "id": 14,
//                "name": "Fantasy"
//            },
//            {
//                "id": 36,
//                "name": "History"
//            },
//            {
//                "id": 27,
//                "name": "Horror"
//            },
//            {
//                "id": 10402,
//                "name": "Music"
//            },
//            {
//                "id": 9648,
//                "name": "Mystery"
//            },
//            {
//                "id": 10749,
//                "name": "Romance"
//            },
//            {
//                "id": 878,
//                "name": "Science Fiction"
//            },
//            {
//                "id": 10770,
//                "name": "TV Movie"
//            },
//            {
//                "id": 53,
//                "name": "Thriller"
//            },
//            {
//                "id": 10752,
//                "name": "War"
//            },
//            {
//                "id": 37,
//                "name": "Western"
//            }
//        ]
//    }
//}


struct ImagePath {
    private static let baseUrl = "https://image.tmdb.org/t/p/"

    static func path(path: String, size: String) -> String {
        return baseUrl + "/" + size + "/" + path
    }
}

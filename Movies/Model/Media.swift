//
//  Movie.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

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

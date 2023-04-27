//
//  Movie.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

struct Movie: Decodable, Identifiable {
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String
    let releaseDate: String?
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
}

extension Movie {
    static var preview: Movie = Movie(
        adult: false,
        backdropPath: "/ndlQ2Cuc3cjTL7lTynw6I4boP4S.jpg",
        genreIds: [
            14,
            28,
            80
        ],
        id: 1,
        originalLanguage: "en",
        originalTitle: "Suicide Squad",
        overview: "From DC Comics comes the Suicide Squad, an antihero team of incarcerated supervillains who act as deniable assets for the United States government, undertaking high-risk black ops missions in exchange for commuted prison sentences.",
        popularity: 48.261451,
        posterPath: "/e1mjopzAS2KNsvpbpahQ1a6SkSn.jpg",
        releaseDate: "2016-08-03",
        title: "Suicide Squad",
        video: false,
        voteAverage: 5.12,
        voteCount: 1466
    )
}

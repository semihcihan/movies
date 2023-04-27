//
//  AppEnvironment.swift
//  Movies
//
//  Created by Semih Cihan on 26.04.2023.
//

//import UIKit
//import Combine
//
//struct AppEnvironment {
//    let services: Services
//}
//
//extension AppEnvironment {
//
//    static func bootstrap() -> AppEnvironment {
//        let services: Services
//
//        let session = configuredURLSession()
//        let webRepositories = configuredWebRepositories(session: session)
//        let dbRepositories = configuredDBRepositories(appState: appState)
//        let services = configuredServices(appState: appState,
//                                          dbRepositories: dbRepositories,
//                                          webRepositories: webRepositories)
//        let diContainer = DIContainer(appState: appState, services: services)
//        let deepLinksHandler = RealDeepLinksHandler(container: diContainer)
//        let pushNotificationsHandler = RealPushNotificationsHandler(deepLinksHandler: deepLinksHandler)
//        let systemEventsHandler = RealSystemEventsHandler(
//            container: diContainer, deepLinksHandler: deepLinksHandler,
//            pushNotificationsHandler: pushNotificationsHandler,
//            pushTokenWebRepository: webRepositories.pushTokenWebRepository)
//        return AppEnvironment(container: diContainer,
//                              systemEventsHandler: systemEventsHandler)
//    }
//
//    private static func configuredURLSession() -> URLSession {
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 60
//        configuration.timeoutIntervalForResource = 120
//        configuration.waitsForConnectivity = true
//        configuration.httpMaximumConnectionsPerHost = 5
//        configuration.requestCachePolicy = .returnCacheDataElseLoad
//        configuration.urlCache = .shared
//        return URLSession(configuration: configuration)
//    }
//
//    private static func configuredRepository(session: URLSession) -> Repository {
//        let countriesWebRepository = RealCountriesWebRepository(
//            session: session,
//            baseURL: "https://restcountries.com/v2")
//        let imageWebRepository = RealImageWebRepository(
//            session: session,
//            baseURL: "https://ezgif.com")
//        let pushTokenWebRepository = RealPushTokenWebRepository(
//            session: session,
//            baseURL: "https://fake.backend.com")
//        return .init(imageRepository: imageWebRepository,
//                     countriesRepository: countriesWebRepository,
//                     pushTokenWebRepository: pushTokenWebRepository)
//    }
//
//    private static func configuredServices(appState: Store<AppState>,
//                                           dbRepositories: DIContainer.DBRepositories,
//                                           webRepositories: DIContainer.WebRepositories
//    ) -> Services {
//
//        let countriesService = RealCountriesService(
//            webRepository: webRepositories.countriesRepository,
//            dbRepository: dbRepositories.countriesRepository,
//            appState: appState)
//
//        let imagesService = RealImagesService(
//            webRepository: webRepositories.imageRepository)
//
//        let userPermissionsService = RealUserPermissionsService(
//            appState: appState, openAppSettings: {
//                URL(string: UIApplication.openSettingsURLString).flatMap {
//                    UIApplication.shared.open($0, options: [:], completionHandler: nil)
//                }
//            })
//
//        return .init(countriesService: countriesService,
//                     imagesService: imagesService,
//                     userPermissionsService: userPermissionsService)
//    }
//}
//
//struct Services {
//    let movieService: MovieService
//
//    init(movieService: MovieService) {
//        self.movieService = movieService
//    }
//}

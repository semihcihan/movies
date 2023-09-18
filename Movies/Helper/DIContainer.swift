//
//  DependencyInjector.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation

protocol DIContainerProtocol: ObservableObject {
    func register<Component>(type: Component.Type, component: Any)
    func resolve<Component>(type: Component.Type) -> Component
}

final class DIContainer: DIContainerProtocol {
    static let shared = DIContainer()

    private init() {}

    var components: [String: Any] = [:]

    func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }

    func resolve<Component>(type: Component.Type) -> Component {
        guard let component = components["\(type)"] as? Component else {
            fatalError("Register your component")
        }
        return component
    }
}

extension DIContainer {
    static func bootstrap() {
        DIContainer.shared.register(type: MediaService.self, component: RealMediaService(movieRepository: RealMediaRepository()))
        DIContainer.shared.register(type: ImageService.self, component: RealImageService())
        DIContainer.shared.register(type: GenreService.self, component: RealGenreService(genreRepository: RealGenreRepository()))
    }
}

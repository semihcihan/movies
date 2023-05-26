//
//  DependencyInjector.swift
//  Movies
//
//  Created by Semih Cihan on 22.05.2023.
//

import Foundation

protocol DIContainerProtocol {
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
        return components["\(type)"] as! Component
    }
}

extension DIContainer {
    static func bootstrap() {
        DIContainer.shared.register(type: RealMovieService.self, component: RealMovieService(movieRepository: RealMovieRepository()))
        DIContainer.shared.register(type: ImageService.self, component: RealImageService())
    }
}

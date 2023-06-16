//
//  ScannerViewController.swift
//  Movies
//
//  Created by Semih Cihan on 9.06.2023.
//

import UIKit
import SwiftUI
import VisionKit

struct ScannerViewControllerRepresentable: UIViewControllerRepresentable {
    let mediaService: MediaService
    let genreService: GenreService
    
    init(mediaService: MediaService = DIContainer.shared.resolve(type: MediaService.self),
         genreService: GenreService = DIContainer.shared.resolve(type: GenreService.self)) {
        self.mediaService = mediaService
        self.genreService = genreService
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, mediaService: mediaService, genreService: genreService)
    }
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .accurate,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true)
        controller.delegate = context.coordinator
        #if targetEnvironment(simulator)
        context.coordinator.dataScannerForSimulator = controller
        #endif
        do {
            try controller.startScanning()
        } catch {
            print("---", error)
        }
        return controller
    }        
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        coordinator.hostingController?.dismiss(animated: true)
        coordinator.hostingController = nil
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, DataScannerViewControllerDelegate {
        var allItems: [(RecognizedItem.Text, Media)] = []
        var mediaService: MediaService
        var genreService: GenreService
        var scannedMediaView: ScannedMediaView
        var hostingController: UIHostingController<ScannedMediaView>?
        
        #if targetEnvironment(simulator)
        var dataScannerForSimulator: DataScannerViewController!
        #endif
        
        init(_ controller: ScannerViewControllerRepresentable, mediaService: MediaService, genreService: GenreService) {
            self.mediaService = mediaService
            self.genreService = genreService
            
            scannedMediaView = ScannedMediaView(viewModel: ScannedMediaView.ViewModel(mediaService: mediaService, genreService: genreService))
            
            hostingController = UIHostingController(rootView: scannedMediaView)
            super.init()
                        
            #if targetEnvironment(simulator)
            Task {
                try? await Task.sleep(for:.seconds(1))
                self.didTapOnSimulator(dataScannerForSimulator!)
            }
            Task {
                try? await Task.sleep(for:.seconds(3))
                self.didTapOnSimulator(dataScannerForSimulator!)
            }
            #endif
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            //TODO: check if hosting controller is already presented or not
            
            if dataScanner.presentedViewController != hostingController {
                setupSheet()
                dataScanner.present(hostingController!, animated: true, completion: nil)
            }
            
            fetchMediaFor(item)
        }
        
        func setupSheet() {
            if let sheet = hostingController!.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.largestUndimmedDetentIdentifier = .medium
            }
        }
        
        #if targetEnvironment(simulator)
        func didTapOnSimulator(_ dataScanner: DataScannerViewController) {
            if dataScanner.presentedViewController != hostingController {
                setupSheet()
                dataScanner.present(hostingController!, animated: true, completion: nil)
            }
                        
            scannedMediaView.viewModel.searchText = "Inter"
        }
        #endif
        
        func fetchMediaFor(_ item: RecognizedItem) {
            switch item {
                case .text(let text):
                    scannedMediaView.viewModel.searchText = text.transcript
                    break
                default:
                    break
            }
        }
    }
}

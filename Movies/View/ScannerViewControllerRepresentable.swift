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
    
    func makeUIViewController(context: Context) -> MyDataScannerViewController {
        let controller = MyDataScannerViewController(
            dataScanner: DataScannerViewController(
                recognizedDataTypes: [.text()],
                qualityLevel: .accurate,
                recognizesMultipleItems: true,
                isHighFrameRateTrackingEnabled: false,
                isHighlightingEnabled: true),
            mediaService: mediaService,
            genreService: genreService
        )
        return controller
    }        
        
    func updateUIViewController(_ uiViewController: MyDataScannerViewController, context: Context) { }
}

class MyDataScannerViewController: UIViewController, DataScannerViewControllerDelegate {
    static var isSupported: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return DataScannerViewController.isSupported
        #endif
    }
    static var isAvailable: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return DataScannerViewController.isAvailable
        #endif
    }
    private var allItems: [(RecognizedItem.Text, Media)] = []
    private var mediaService: MediaService
    private var genreService: GenreService
    private var scannedMediaView: ScannedMediaView
    private var hostingController: UIHostingController<ScannedMediaView>?
    private let dataScanner: DataScannerViewController!
    private var task: Task<(), Error>?
    var dataScannerBottomConstraint: NSLayoutConstraint?
        
    init(dataScanner: DataScannerViewController, mediaService: MediaService, genreService: GenreService) {
        self.dataScanner = dataScanner
        self.mediaService = mediaService
        self.genreService = genreService
        self.scannedMediaView = ScannedMediaView(viewModel: ScannedMediaView.ViewModel(mediaService: mediaService, genreService: genreService))
        self.hostingController = UIHostingController(rootView: scannedMediaView)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildren()
        
#if targetEnvironment(simulator)
        Task {
            try? await Task.sleep(for:.seconds(1))
            self.didTapOnSimulator(self.dataScanner)
        }
#endif
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startScanning()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dataScanner.stopScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
                        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.parent?.navigationItem.largeTitleDisplayMode = .never
    }
        
    func startScanning() {
        guard Self.isAvailable else {
            checkAvailability()
            return
        }
        do {
            try dataScanner.startScanning()
        } catch {
            print("---", error) //TODO: handle
        }
    }
    
    func setupChildren() {
        dataScanner.delegate = self
        addChild(dataScanner)
        view.addSubview(dataScanner.view)
        #if targetEnvironment(simulator)
        dataScanner.view.backgroundColor = .red
        #endif
        
        addChild(hostingController!)
        let resultsView = hostingController!.view!
        view.addSubview(resultsView)
        
        dataScanner.view.translatesAutoresizingMaskIntoConstraints = false
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dataScanner.view.topAnchor.constraint(equalTo: view.topAnchor),
            dataScanner.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dataScanner.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.topAnchor.constraint(equalTo: dataScanner.view.bottomAnchor),
        ])
        
        dataScannerBottomConstraint = dataScanner.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        dataScannerBottomConstraint?.isActive = true
        
        setupScannedMediaHeight()
    }
        
    func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
        self.fetchMediaFor(item)
    }
    
    func checkAvailability() {
        guard !Self.isAvailable else {
            return
        }
        
        let alert = UIAlertController(title: "Camera Access", message: "Camera access is required to scan movie & tv show names.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Go to settings", comment: "Default action"), style: .default, handler: { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
#if targetEnvironment(simulator)
    func didTapOnSimulator(_ dataScanner: DataScannerViewController) {
        self.scannedMediaView.viewModel.startExternalSearch(with: "Inter")
    }
#endif
    
    private let identifier = UISheetPresentationController.Detent.Identifier("sheet")
    func setupScannedMediaHeight() {
        Task {
            for await height in scannedMediaView.viewModel.$contentHeight.values {
                self.dataScannerBottomConstraint?.constant = -height
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func fetchMediaFor(_ item: RecognizedItem) {
        switch item {
            case .text(let text):
                scannedMediaView.viewModel.startExternalSearch(with: text.transcript)
                break
            default:
                break
        }
    }
}

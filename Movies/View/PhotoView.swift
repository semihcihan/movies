//
//  PhotoView.swift
//  Movies
//
//  Created by Semih Cihan on 20.04.2023.
//

import SwiftUI

struct PhotoView: View {
    @StateObject private var viewModel: PhotoViewModel
    @State private var heartScale = 1.0
    @State private var imageScale = 1.0
    
    @State private var magnificationPrevValue = 1.0
    @State private var translationPrevValue: CGSize = .zero
    @State private var imageOffset: CGSize = .zero
    
    let animationDuration = 0.2
    
    init(photo: Photo) {
        _viewModel = StateObject(wrappedValue: { PhotoViewModel(photo: photo) }())
    }
    
    func resetImageState() {
        return withAnimation(.spring()) {
            imageScale = 1
            imageOffset = .zero
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation(.linear(duration: 0.1)) {
                    imageOffset = CGSizeMake(imageOffset.width + value.translation.width - translationPrevValue.width, imageOffset.height + value.translation.height - translationPrevValue.height)
                    
                    translationPrevValue = value.translation
                }
            }
            .onEnded { _ in
                translationPrevValue = .zero
            }
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                withAnimation(.linear(duration: 0.3)) {
                    let newScale = imageScale + value - magnificationPrevValue
                    magnificationPrevValue = value
                    if newScale >= 1 && newScale <= 5 {
                        imageScale = newScale
                    } else if newScale > 5 {
                        imageScale = 5
                    } else if newScale < 1 {
                        imageScale = 1
                    }
                }
            }
            .onEnded { _ in
                magnificationPrevValue = 1
                if imageScale > 5 {
                    imageScale = 5
                } else if imageScale <= 1 {
                    resetImageState()
                }
            }
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        imageScale == 1 ? Image(systemName: viewModel.liked ? "heart.fill" : "heart")
                            .font(.largeTitle)
                            .scaleEffect(heartScale)
                            .foregroundColor(viewModel.liked ? .pink : .white)
                            .padding()
                            .onTapGesture {
                                withAnimation(Animation.easeInOut(duration: animationDuration)) {
                                    heartScale = 1.2
                                    viewModel.like()
                                }
                                
                                withAnimation(Animation.easeInOut(duration: animationDuration).delay(animationDuration)) {
                                    heartScale = 1
                                }
                            } : nil,
                        alignment: .bottomLeading
                    )
                    .offset(x: imageOffset.width, y: imageOffset.height)
                    .scaleEffect(imageScale)
                    .onTapGesture(count: 2, perform: { point in
                        if imageScale == 1 {
                            withAnimation(.linear(duration: animationDuration)) {
                                imageScale = 5
                            }
                        } else {
                            resetImageState()
                        }
                    })
                    .gesture(drag)
                    .gesture(magnification)
                
            } else {
                Color(.black)
            }
        }
        .onAppear {
            self.viewModel.loadImage(\.original)
        }
        .onDisappear {
            self.viewModel.releaseImage()
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(photo: Photo.preview)
    }
}

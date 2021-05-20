//
//  CameraMainView.swift
//  RPSGame
//
//  Created by Aly Kamel on 14/10/20.
//

import SwiftUI

struct CameraMainView: View {
    @State var image: Image? = nil
    @State var showCaptureImageView: Bool = false
    
    var body: some View {
        ZStack {
          VStack {
            Button(action: {
              self.showCaptureImageView.toggle()
            }) {
              Text("Choose photos")
            }
            image?.resizable()
              .frame(width: 250, height: 200)
              .clipShape(Circle())
              .overlay(Circle().stroke(Color.white, lineWidth: 4))
              .shadow(radius: 10)
          }
          if (showCaptureImageView) {
            CaptureImageView(isShown: $showCaptureImageView, image: $image)
          }
        }
    }
}

struct CameraMainView_Previews: PreviewProvider {
    static var previews: some View {
        CameraMainView()
    }
}

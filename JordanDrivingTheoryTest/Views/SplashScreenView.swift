//
//  SplashScreenView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 26/08/2025.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var animateShine = false
    
    var body: some View {
        ZStack {
            // Background red
            Color.white.ignoresSafeArea()
            
            VStack() {
                ZStack {
                    // Black pillars of the H
                    HStack(spacing: 115) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 65, height:360)
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 65, height: 360)
                    }
                    ZStack {
                        ArcShape()
                            .fill(Color.white)
                            .frame(width: 130, height: 60)
                            .offset(y: 3)
                        // Golden arc in the middle
                        ArcShape()
                            .fill(Color.red)
                            .frame(width: 120, height: 50)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .clear,
                                        Color.white.opacity(0.9),
                                        .clear
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .frame(width: 120, height: 200)
                                .offset(x: animateShine ? 200 : -200)
                                .mask(
                                    ArcShape()
                                        .frame(width: 120, height: 50)
                                )
                                .offset(y: 0)
                            )
                    }.offset(y: 32)
                    
                }.padding(.vertical, 200)
                
                // "The Hub Studios"
                Text("The Hub Studios®")
                    .foregroundColor(.black)
                    .bold(true)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animateShine.toggle()
            }
        }
    }
}

// Custom arc shape for the golden bar
struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.maxY),
                    radius: rect.width / 1.3,
                    startAngle: .degrees(-35),
                    endAngle: .degrees(-145),
                    clockwise: true)
        return path.strokedPath(.init(lineWidth: rect.height))
    }
}




#Preview {
    SplashScreenView()
}

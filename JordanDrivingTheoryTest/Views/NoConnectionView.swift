//
//  NoConnectionView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 10/09/2025.
//

import SwiftUI

struct NoConnectionView: View {
    var body: some View {
        ZStack {
            Color.red.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text(localizedKey: "No Wi-Fi Connection")
                    .font(.title)
                    .foregroundColor(.white)
                
                Text(localizedKey: "Please connect to Wi-Fi to use this app.")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
}


#Preview {
    NoConnectionView()
}

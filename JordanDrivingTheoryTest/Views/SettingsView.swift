//
//  SettingsView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 16/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        ZStack {
            Image("backdrop2").resizable().scaledToFill().ignoresSafeArea().opacity(0.7)
            VStack(spacing: 20) {
                
                if !purchaseManager.hasRemovedAds {
                    Button {
                        Task {
                            await purchaseManager.purchaseRemoveAds()
                        }
                    } label: {
                        HStack {
                            Text(localizedKey: "Remove Ads")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: 350)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(500)
                    }
                } else {
                    Text("Ads Removed ✅")
                }
                Button {
                    Task {
                        await purchaseManager.restorePurchases()
                    }
                } label: {
                    HStack {
                        Text(localizedKey: "Restore Purchases")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 350)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(500)
                }
                .padding()
                .foregroundColor(.blue)
            }
            .padding()
        }
    }
}


#Preview {
    SettingsView()
}

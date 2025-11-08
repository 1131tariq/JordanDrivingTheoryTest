//
//  SettingsView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 16/09/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPurchasing = false
    @State private var isRestoring = false
    
    var body: some View {
        ZStack {
            // Background
            Image("backdrop2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.7)
            
            VStack(spacing: 24) {
                // Back button
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left")
                        Text(NSLocalizedString("main_menu", bundle: .localized, comment: ""))
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Remove Ads Button
                if !purchaseManager.hasRemovedAds {
                    Button {
                        Task {
                            withAnimation { isPurchasing = true }
                            await purchaseManager.purchaseRemoveAds()
                            withAnimation { isPurchasing = false }
                        }
                    } label: {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.2)
                            } else {
                                Text(localizedKey: "Remove Ads & Unlock Offline Mode")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: 350)
                        .padding()
                        .background(isPurchasing ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(500)
                    }
                    .disabled(isPurchasing || purchaseManager.products.isEmpty)
                } else {
                    Text("Ads Removed ✅")
                        .font(.headline)
                        .padding(.top)
                }
                
                // Restore Purchases Button
                Button {
                    Task {
                        withAnimation { isRestoring = true }
                        await purchaseManager.restorePurchases()
                        withAnimation { isRestoring = false }
                    }
                } label: {
                    HStack {
                        if isRestoring {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        } else {
                            Text(localizedKey: "Restore Purchases")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: 350)
                    .padding()
                    .background(isRestoring ? Color.gray : Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(500)
                }
                .disabled(isRestoring)
                
                Spacer()
            }
            .padding()
            
            // Loading overlay
            if isPurchasing || isRestoring {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text(isPurchasing ? "Connecting to App Store…" : "Restoring purchases…")
                        .foregroundColor(.white)
                        .font(.headline)
                        .opacity(0.9)
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(16)
                .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut, value: isPurchasing || isRestoring)
    }
}

#Preview {
    SettingsView()
        .environmentObject(PurchaseManager())
}

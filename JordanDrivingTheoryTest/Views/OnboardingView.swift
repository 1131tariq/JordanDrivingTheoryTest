//
//  OnboardingView.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 23/08/2025.
//

import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("language") private var language: String = "en"
    
    @State private var currentPage = 0
    let onFinish: () -> Void
    
    var body: some View {
        ZStack {
            // 🔹 Subtle animated background for polish

            
            Image("backdrop2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.35)
                .blur(radius: 0.5)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: UUID())
            
            // 🔹 Pages
            TabView(selection: $currentPage) {
                languageSelectionPage.tag(0)
                welcomePage.tag(1)
                notificationPermissionPage.tag(2)
                imageEnlargeTipPage.tag(3)
                purchaseInfoPage.tag(4)
                finalPage.tag(5)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
        }
    }
    
    // MARK: - Pages
    
    private var languageSelectionPage: some View {
        VStack(spacing: 30) {
            Text(localizedKey: "choose_language")
                .font(.largeTitle)
                .fontWeight(.bold)
                .shadow(radius: 3)
            
            HStack(spacing: 30) {
                ForEach(["en", "ar"], id: \.self) { lang in
                    Button {
                        language = lang
                        LocalizedBundle.setLanguage(lang)
                        currentPage = 1
                    } label: {
                        Text(lang == "en" ? "English" : "العربية")
                            .frame(width: 130)
                            .padding()
                            .background(lang == "en" ? Color.orange : Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 4)
                    }
                }
            }
        }
        .padding()
    }
    
    private var welcomePage: some View {
        VStack(spacing: 20) {
            Text(localizedKey: "welcome_title")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "welcome_body")
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)
                .font(.title3)
                .foregroundColor(.primary.opacity(0.9))
            
            nextButton {
                currentPage = 2
            }
        }
        .onAppear { LocalizedBundle.setLanguage(language) }
    }
    
    private var notificationPermissionPage: some View {
        VStack(spacing: 25) {
            Text(localizedKey: "get_reminders")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Image(systemName: "bell.badge.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.orange)
                .shadow(radius: 4)
                .padding(.bottom, 10)
            
            Text(localizedKey: "reminder_body")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .frame(maxWidth: 300)
            
            nextButton {
                requestNotificationPermission()
                currentPage = 3
            } label: {
                Text(localizedKey: "allow_notifications")
            }
        }
    }
    
    // MARK: - Interactive Exam Demo
    
    private var imageEnlargeTipPage: some View {
        VStack(spacing: 25) {
            Text(localizedKey:"📷 Exam Interaction")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .shadow(radius: 2)
            
            ZStack {
                Color.clear // background placeholder

                VStack {
                    VStack(spacing: 16) {
                        Text("1 / 40")
                            .font(.title2).bold()

                        ProgressView(value: 0.25)
                            .tint(.yellow)
                            .padding(.horizontal, 16)

                        EnlargingExamImageDemo(imageName: "5.39")
                            .frame(width: 140, height: 100)
                            .padding(.top, 8)

                        Text(localizedKey:"exam_question_text")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)

                        ScrollChoicesDemo()
                            .frame(height: 100)
                    }
                    .padding(10)
                    .frame(width: 200) // smaller “screen width”
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black, lineWidth: 1)
                            .background(Color.white.opacity(0.05))
                    )
                    .shadow(radius: 3)
                    .scaleEffect(0.85) // 🔹 scale down all content
                    .overlay(
                        VStack {
                            Spacer()
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                                .opacity(0.8)
                                .offset(y: 4)
                                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: UUID())
                        }
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            
            Text(localizedKey: "Tap any image to enlarge it, and scroll to explore all choices.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.horizontal)
            
            nextButton { currentPage = 4 }
        }
        .padding()
    }

    // MARK: - Purchase Info Page
    
    private var purchaseInfoPage: some View {
        VStack(spacing: 25) {
            Text(localizedKey: "Unlock More Features")
                .font(.largeTitle)
                .bold()
            
            Image(systemName: "creditcard.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 70)
                .foregroundColor(.yellow)
                .shadow(radius: 5)
                .padding(.bottom, 10)
            
            Text(localizedKey: "Remove ads and unlock Offline Mode anytime from the 🛒 screen in the main menu.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding()
                .font(.title3)
            
            Text(localizedKey:"Enjoy an ad-free experience and study without needing an internet connection!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            nextButton { currentPage = 5 }
        }
        .padding()
    }
    
    // MARK: - Final Page
    
    private var finalPage: some View {
        VStack(spacing: 25) {
            Text(localizedKey: "ready_title")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "ready_body")
                .multilineTextAlignment(.center)
                .padding()
                .font(.title3)
                .foregroundColor(.primary.opacity(0.9))
            
            nextButton {
                hasSeenOnboarding = true
                onFinish()
            } label: {
                Text(localizedKey: "lets_start")
            }
        }
    }
    
    // MARK: - Helper Components
    
    private func nextButton(action: @escaping () -> Void, label: (() -> Text)? = nil) -> some View {
        Button(action: action) {
            (label?() ?? Text(localizedKey: "next"))
                .frame(maxWidth: 240)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
        }
        .padding(.top, 5)
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                if granted { scheduleReminderNotification() }
            }
    }
    
    private func scheduleReminderNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("reminder_title", bundle: .localized, comment: "")
        content.body  = NSLocalizedString("reminder_message", bundle: .localized, comment: "")
        
        var date = DateComponents()
        date.hour = 15
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
// MARK: - Image enlarge animation with auto-enlarge once
struct EnlargingExamImageDemo: View {
    let imageName: String
    @State private var isEnlarged = false
    @State private var didAutoEnlarge = false
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .cornerRadius(12)
            .shadow(radius: 5)
            .scaleEffect(isEnlarged ? 1.25 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.65), value: isEnlarged)
            .onAppear {
                guard !didAutoEnlarge else { return }
                didAutoEnlarge = true
                withAnimation(.spring()) {
                    isEnlarged = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring()) {
                        isEnlarged = false
                    }
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    isEnlarged.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.spring()) {
                        isEnlarged = false
                    }
                }
            }
    }
}

// MARK: - Auto Scroll Choices Animation (continuous)
struct ScrollChoicesDemo: View {
    @State private var scrollOffset: CGFloat = 0
    private let choices = [
        "Vehicles wider than 2.2m are prohibited.",
        "Vehicles taller than 2.2m are prohibited.",
        "Vehicles longer than 2.2m are prohibited.",
        "None of the above."
    ]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(choices.indices, id: \.self) { i in
                        Text(choices[i])
                            .padding()
                            .frame(maxWidth: 260)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .id(i)
                    }
                }
                .padding(.vertical)
            }
            .onAppear {
                Task {
                    while true { // continuous scroll loop
                        for i in choices.indices {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                proxy.scrollTo(i, anchor: .top)
                            }
                            try? await Task.sleep(nanoseconds: 800_000_000)
                        }
                        for i in choices.indices.reversed() {
                            withAnimation(.easeInOut(duration: 1.2)) {
                                proxy.scrollTo(i, anchor: .top)
                            }
                            try? await Task.sleep(nanoseconds: 800_000_000)
                        }
                    }
                }
            }
        }
    }
}

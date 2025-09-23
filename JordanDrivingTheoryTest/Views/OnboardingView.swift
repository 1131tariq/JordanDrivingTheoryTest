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
            Image("backdrop2").resizable()
                .scaledToFill()
                .ignoresSafeArea().opacity(0.4)
            
            TabView(selection: $currentPage) {
                // 1️⃣ Language selection is page 0
                languageSelectionPage
                    .tag(0)
                
                // 2️⃣ Welcome is now page 1
                welcomePage
                    .tag(1)
                
                // 3️⃣ Notifications page
                notificationPermissionPage
                    .tag(2)
                
                // 4️⃣ Final “Let’s Start” page
                finalPage
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle())
            .animation(.easeInOut, value: currentPage)
        }
    }
    
    // MARK: Pages
    
    private var languageSelectionPage: some View {
        VStack {
            VStack(spacing: 20) {
                Text(localizedKey: "choose_language")
                    .font(.largeTitle).bold()
                
                
                HStack(spacing: 30) {
                    Button {
                        language = "en"
                        LocalizedBundle.setLanguage("en")
                        currentPage = 1  // move to Welcome
                    } label: {
                        Text("English")
                            .frame(width: 120)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        language = "ar"
                        LocalizedBundle.setLanguage("ar")
                        currentPage = 1  // move to Welcome
                    } label: {
                        Text("العربية")
                            .frame(width: 120)
                            .padding()
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
    }
    
    private var welcomePage: some View {
        VStack(spacing: 20) {
            Text(localizedKey: "welcome_title")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "welcome_body")
                .padding()
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            
            
            Button {
                currentPage = 2  // move to Notifications
            } label: {
                Text(localizedKey: "next")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .onAppear {
            // ensure text here is immediately localized
            LocalizedBundle.setLanguage(language)
        }
    }
    
    private var notificationPermissionPage: some View {
        VStack(spacing: 20) {
            Text(localizedKey: "get_reminders")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "reminder_body")
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                requestNotificationPermission()
                currentPage = 3  // move to Final
            } label: {
                Text(localizedKey: "allow_notifications")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    private var finalPage: some View {
        VStack(spacing: 20) {
            Text(localizedKey: "ready_title")
                .font(.largeTitle)
                .bold()
            
            Text(localizedKey: "ready_body")
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                hasSeenOnboarding = true
                onFinish()
            } label: {
                Text(localizedKey: "lets_start")
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    // MARK: Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
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
        
        let request = UNNotificationRequest(identifier: "dailyReminder",
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

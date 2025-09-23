//
//  NetworkMonitor.swift
//  JordanDrivingTheoryTest
//
//  Created by Tareq Batayneh on 10/09/2025.

import Foundation
import Network
import Combine

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    @Published var lastUpdate: Date = Date() // 🔑 Use this to detect changes
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newStatus = (path.status == .satisfied)
                if self?.isConnected != newStatus {
                    self?.isConnected = newStatus
                    self?.lastUpdate = Date() // 🔑 update every time status changes
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

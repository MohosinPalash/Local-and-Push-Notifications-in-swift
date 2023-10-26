//
//  LocalNotificationApp.swift
//  LocalNotification
//
//  Created by Mohosin Islam Palash on 25/10/23.
//

import SwiftUI

@main
struct LocalNotificationApp: App {
    @StateObject var localNotificationManager = LocalNotificationManager()
    var body: some Scene {
        WindowGroup {
            NotificationsListView()
                .environmentObject(localNotificationManager)
        }
    }
}

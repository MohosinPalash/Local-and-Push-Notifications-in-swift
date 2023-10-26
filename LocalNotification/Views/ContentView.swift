//
//  ContentView.swift
//  LocalNotification
//
//  Created by Mohosin Islam Palash on 25/10/23.
//

import SwiftUI

struct NotificationsListView: View {
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    @Environment(\.scenePhase) var scenePhase
    @State private var scheduleDate = Date()
    var body: some View {
        NavigationView {
            VStack {
                if localNotificationManager.isGranted {
                    GroupBox("Schedule") {
                        Button("Interval Ntification") {
                            Task {
                                var localNotification = LocalNotification(identifier: UUID().uuidString,
                                                                          title: "Title of notification",
                                                                          body: "Body of notification",
                                                                          timeInvterval: 5,
                                                                          repeats: false)
                                localNotification.subtitle = "This is a subtitle."
                                localNotification.bundleImageName = "icon_call_blue.png"
                                localNotification.userInfo = ["nextView" : NextView.renew.rawValue]
                                localNotification.categoryIdentifier = "snooze"
                                await localNotificationManager.schedule(localNotification: localNotification)
                            }
                        }
                        .buttonStyle(.bordered)
                        GroupBox {
                            DatePicker("", selection: $scheduleDate)
                            Button("Calendar Notification") {
                                Task {
                                    let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduleDate)
                                    let localNotification = LocalNotification(identifier: UUID().uuidString,
                                                                              title: "Calendar Notification",
                                                                              body: "Body of the calendar notification",
                                                                              dateComponents: dateComponents,
                                                                              repeats: false)
                                    await localNotificationManager.schedule(localNotification: localNotification)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        Button("Promo Offer") {
                            Task {
                                let dateComponents = DateComponents(day: 1, hour: 10, minute: 0)
                                var localNotification = LocalNotification(identifier: UUID().uuidString,
                                                                          title: "Promo Offer",
                                                                          body: "Grab the offer now",
                                                                          dateComponents: dateComponents,
                                                                          repeats: false)
                                localNotification.userInfo = ["nextView" : NextView.promo.rawValue]
                                await localNotificationManager.schedule(localNotification: localNotification)
                            }
                        }
                    }
                    .frame(width: 300)
                    List {
                        ForEach(localNotificationManager.pendingRequests, id: \.identifier) { request in
                            VStack(alignment: .leading) {
                                Text(request.content.title)
                                Text(request.identifier)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    localNotificationManager.removeRequest(withIdentififer: request.identifier)
                                }
                            }
                        }
                    }
                } else {
                    Button("Enable Notofication") {
                        localNotificationManager.openSettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
            }
            .sheet(item: $localNotificationManager.nextView, content: { nextView in
                nextView.view()
            })
            .navigationTitle("Local Notification")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        localNotificationManager.clearRequests()
                    } label: {
                        Text("Clear All")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .task {
            try? await localNotificationManager.requestAuthorization()
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                Task {
                    await localNotificationManager.getCurrentSettings()
                    await localNotificationManager.getPendingRequests()
                }
            }
        }
    }
}

struct NotificationsListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsListView()
            .environmentObject(LocalNotificationManager())
    }
}

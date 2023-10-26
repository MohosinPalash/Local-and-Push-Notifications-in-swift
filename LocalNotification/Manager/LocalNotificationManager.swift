//
//  LocalNotificationManager.swift
//  LocalNotification
//
//  Created by Mohosin Islam Palash on 25/10/23.
//

import Foundation
import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject {
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isGranted = false
    @Published var pendingRequests: [UNNotificationRequest] = []
    @Published var nextView: NextView?
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    //Checking Authorization
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        registerActions()
        await getCurrentSettings()
    }
    
    //Checking the current notification settings whether permission is given or denied
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
        print(isGranted)
    }
    
    //To redirect to open Settings feature of the device where one can change the authorization request
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    //Create and add notification
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        if let subtitle = localNotification.subtitle {
            content.subtitle = subtitle
        }
        if let bundleImageName = localNotification.bundleImageName {
            if let url = Bundle.main.url(forResource: bundleImageName, withExtension: "") {
                if let attachment  = try? UNNotificationAttachment(identifier: bundleImageName, url: url) {
                    content.attachments = [attachment]
                }
            }
        }
        if let userInfo = localNotification.userInfo {
            content.userInfo = userInfo
        }
        if let categoryIdentifier = localNotification.categoryIdentifier {
            content.categoryIdentifier = categoryIdentifier
        }
        content.sound = .default
        if localNotification.scheduleType == .time {
            guard let timeInterval = localNotification.timeInvterval else { return }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            try? await notificationCenter.add(request)
        } else {
            guard let dateComponents = localNotification.dateComponents else { return }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            try? await notificationCenter.add(request)
        }
        await getPendingRequests()
    }
    
    //Get pending requests
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        //print("Pending: \(pendingRequests.count)")
    }
    
    //Delete pending requests
    func removeRequest(withIdentififer identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: {$0.identifier ==  identifier}) {
            pendingRequests.remove(at: index)
            //print("Pending: \(pendingRequests.count)")
        }
    }
    
    //Delete all pending requests
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
        print("Pending: \(pendingRequests.count)")
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    
    //Delegate function: To show the notification when the app is in foreground state
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await getPendingRequests()
        return [.sound, .banner]
    }
    
    func registerActions() {
        let snooze10Action = UNTextInputNotificationAction(identifier: "snooze10", title: "Snooze 10 seconds")
        let snooze60Action = UNTextInputNotificationAction(identifier: "snooze60", title: "Snooze 60 seconds")
        let snoozeCategory = UNNotificationCategory(identifier: "snooze", actions: [snooze10Action, snooze60Action], intentIdentifiers: [])
        notificationCenter.setNotificationCategories([snoozeCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        if let value = response.notification.request.content.userInfo["nextView"] as? String {
            nextView = NextView(rawValue: value)
        }
        
        //Respond to snooze action
        var snoozeInterval: Double?
        if response.actionIdentifier == "snooze10" {
            snoozeInterval = 10
        } else if response.actionIdentifier == "snooze60" {
            snoozeInterval = 60
        }
        
        if let snoozeInterval = snoozeInterval {
            let content = response.notification.request.content
            let newContent = content.mutableCopy() as! UNMutableNotificationContent
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snoozeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: newContent, trigger: newTrigger)
            
            do {
                try await notificationCenter.add(request)
            } catch {
                print(error.localizedDescription)
            }
            
            await getPendingRequests()
        }
        
    }
}

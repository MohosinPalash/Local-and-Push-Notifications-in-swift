//
//  LocalNotification.swift
//  LocalNotification
//
//  Created by Mohosin Islam Palash on 25/10/23.
//

import Foundation

struct LocalNotification {
    internal init(identifier: String,
                  title: String,
                  body: String,
                  timeInvterval: Double,
                  repeats: Bool) {
        self.identifier = identifier
        self.scheduleType = .time
        self.title = title
        self.body = body
        self.timeInvterval = timeInvterval
        self.dateComponents = nil
        self.repeats = repeats
    }
    
    internal init(identifier: String,
                  title: String,
                  body: String,
                  dateComponents: DateComponents,
                  repeats: Bool) {
        self.identifier = identifier
        self.scheduleType = .calendar
        self.title = title
        self.body = body
        self.timeInvterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
    
    enum ScheduleType {
        case time, calendar
    }
    
    var identifier: String
    var scheduleType: ScheduleType
    var title : String
    var body: String
    var subtitle: String?
    var bundleImageName: String?
    var userInfo: [AnyHashable: Any]?
    var timeInvterval: Double?
    var dateComponents: DateComponents?
    var repeats: Bool
    var categoryIdentifier: String?
}


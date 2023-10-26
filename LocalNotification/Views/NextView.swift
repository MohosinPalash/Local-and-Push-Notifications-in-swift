//
//  NextView.swift
//  LocalNotification
//
//  Created by Mohosin Islam Palash on 26/10/23.
//

import SwiftUI

enum NextView: String, Identifiable {
    case promo, renew
    var id: String {
        self.rawValue
    }
    
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .promo:
            Text("This is a promo view")
        case .renew:
            Text("This is a renew view")
        }
    }
}

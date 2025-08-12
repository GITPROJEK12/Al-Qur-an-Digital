//
//  QuranDigitalApp.swift
//  QuranDigital
//
//  Created by MUHAMAD ALVIANSYAH on 08/07/25.
//

// File: AlquranApp.swift

import SwiftUI

@main
struct QuranDigitalApp: App {
    @AppStorage("appColorScheme") var appColorScheme: Int = 0
    @StateObject private var audioPlayer = AudioPlayerService()

    var activeColorScheme: ColorScheme? {
        switch appColorScheme {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            // ✅ Gunakan MainView sebagai root view
            MainView()
                .environmentObject(audioPlayer)
                .preferredColorScheme(activeColorScheme)
        }
    }
}

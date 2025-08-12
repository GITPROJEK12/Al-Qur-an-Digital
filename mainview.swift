//
//  mainview.swift
//  Al-QuranDigital
//
//  Created by MUHAMAD ALVIANSYAH on 10/07/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Konten Utama Aplikasi (Seluruh Navigasi)
            NavigationView {
                HomeView()
            }
            // Mencegah warna aneh pada navigasi di iPad
            .navigationViewStyle(.stack)

            // 2. MiniPlayer yang Muncul di Atas Semua Tampilan
            if audioPlayer.currentAyat != nil {
                MiniPlayerView()
            }
        }
    }
}

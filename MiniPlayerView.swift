import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService

    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let surahName = audioPlayer.currentSurahName, let ayat = audioPlayer.currentAyat {
                            Text("QS. \(surahName): \(ayat.nomorAyat)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .lineLimit(1)
                        } else {
                            Text("Pilih Ayat")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(audioPlayer.currentQariName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                    HStack(spacing: 25) {
                        Button(action: audioPlayer.playPrevious) {
                            Image(systemName: "backward.fill")
                                .font(.title2)
                        }
                        
                        PlayPauseButton()
                        
                        Button(action: audioPlayer.playNext) {
                            Image(systemName: "forward.fill")
                                .font(.title2)
                        }
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .frame(height: 60)

                // Progress bar di bagian bawah
                ProgressView(value: audioPlayer.playbackProgress)
                    .progressViewStyle(.linear)
                    .tint(.secondary)
                    .frame(height: 2.5)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
            }
            .background(.regularMaterial) // Latar belakang blur
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            // ✅ BINGKAI PLAYER: Tambahkan garis tipis untuk mempertegas
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            }

            // 2. TOMBOL CLOSE "X"
            Button(action: audioPlayer.stop) {
                // ✅ BINGKAI "X": Dibuat lebih menyatu dengan iOS
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.secondary, .ultraThinMaterial)
            }
            // Geser tombol agar setengah keluar
            .offset(x: 10, y: -10)
        }
        // ✅ TIDAK UJUNG KE UJUNG: Padding diperbesar agar tidak menempel di tepi layar
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5) // Bayangan lebih halus
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioPlayer.currentAyat != nil)
    }
}

private struct PlayPauseButton: View {
    @EnvironmentObject var audioPlayer: AudioPlayerService
    
    var body: some View {
        ZStack {
            if audioPlayer.isLoading {
                ProgressView().scaleEffect(1.2)
            } else {
                Button(action: audioPlayer.togglePlayPause) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        LinearGradient(
            gradient: Gradient(colors: [.cyan.opacity(0.3), .blue.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
            
        VStack {
            Text("Miniplayer").font(.largeTitle)
            Spacer()
        }
        
        MiniPlayerView()
            .environmentObject(AudioPlayerService())
    }
}

import Foundation
import AVKit
import Combine

class AudioPlayerService: ObservableObject {
    // MARK: - Published Properties
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var currentAyat: Ayat?
    @Published var currentSurahName: String?
    @Published var playbackProgress: Double = 0.0
    
    // Properti untuk menyimpan nama qari yang sedang aktif
    @Published var currentQariName: String = ""

    // MARK: - Private Properties
    private var player: AVPlayer?
    private var playlist: [Ayat] = []
    private var currentIndex: Int = 0
    private var timeObserver: Any?
    
    // Kamus untuk memetakan ID Qari ke Nama Lengkap
    private let qariNames: [String: String] = [
        "01": "Mishary Rashid Alafasy",
        "02": "Abdul Basit Abdus Samad",
        "03": "Abdurrahman As-Sudais",
        "04": "Maher Al-Muaiqly",
        "05": "Muhammad Thaha Al-Junaid",
    ]
    
    private var qariId: String {
        UserDefaults.standard.string(forKey: "selectedQari") ?? "05"
    }
    
    // Inisialisasi service
    init() {
        updateQariName()
        // Memantau perubahan pada UserDefaults agar nama qari selalu update
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }

    // Fungsi untuk memperbarui nama qari berdasarkan pilihan di UserDefaults
    @objc private func updateQariName() {
        self.currentQariName = qariNames[qariId] ?? "Qari \(qariId)"
    }
    
    @objc private func userDefaultsDidChange() {
        DispatchQueue.main.async {
            self.updateQariName()
        }
    }

    // MARK: - Public API
    func startPlayback(from startAyat: Ayat, in playlist: [Ayat], surahName: String) {
        if self.currentAyat == startAyat {
            togglePlayPause()
            return
        }
        
        self.playlist = playlist
        self.currentSurahName = surahName
        
        guard let index = playlist.firstIndex(of: startAyat) else { return }
        self.currentIndex = index
        
        playCurrentAyat()
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }

    func playNext() {
        guard !playlist.isEmpty else { stop(); return }
        currentIndex = (currentIndex + 1) % playlist.count
        playCurrentAyat()
    }

    func playPrevious() {
        guard !playlist.isEmpty else { stop(); return }
        currentIndex = (currentIndex - 1 + playlist.count) % playlist.count
        playCurrentAyat()
    }

    func stop() {
        cleanupPlayer()
        
        // Reset state
        isPlaying = false
        isLoading = false
        currentAyat = nil
        currentSurahName = nil
        playlist = []
        
        // Nonaktifkan sesi audio
        DispatchQueue.main.async {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    // MARK: - Core Playback Logic
    private func playCurrentAyat() {
        cleanupPlayer()
        
        guard currentIndex < playlist.count else { stop(); return }
        
        let ayatToPlay = playlist[currentIndex]
        
        DispatchQueue.main.async {
            self.currentAyat = ayatToPlay
            self.isLoading = true
        }

        guard let urlString = ayatToPlay.audio?[qariId], let url = URL(string: urlString) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.playNext() }
            return
        }
        
        setupNewPlayer(with: url)
    }

    private func setupNewPlayer(with url: URL) {
        DispatchQueue.main.async {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                self.player = AVPlayer(url: url)
                self.addTimeObserver()
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { [weak self] _ in
                    self?.playNext()
                }

                self.player?.play()
                self.isLoading = false
                self.isPlaying = true

            } catch {
                print("Gagal memulai audio: \(error.localizedDescription)")
                self.stop()
            }
        }
    }
    
    // MARK: - Cleanup and Observers
    private func cleanupPlayer() {
        player?.pause()
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        player = nil
        playbackProgress = 0.0
    }
    
    private func addTimeObserver() {
        guard let player = player else { return }
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self, let duration = self.player?.currentItem?.duration else { return }
            
            if duration.seconds > 0 && time.seconds.isFinite && !time.seconds.isNaN {
                let progress = time.seconds / duration.seconds
                self.playbackProgress = max(0.0, min(1.0, progress))
            }
        }
    }

    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
}

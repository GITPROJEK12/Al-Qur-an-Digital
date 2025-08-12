import SwiftUI

struct HomeView: View {
    @State private var lastRead: LastRead?
    // State untuk animasi
    @State private var showContent = false

    var body: some View {
        ZStack {
            // Latar Belakang Gradient yang lembut
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // Konten Utama
            ScrollView {
                VStack(spacing: 30) {
                    HeaderView()
                    MenuView(lastRead: $lastRead)
                }
                .padding()
                .padding(.bottom, 100)
                // Animasi saat konten muncul
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Al-Qur'an Digital")
        .navigationBarHidden(true)
        .onAppear {
            self.lastRead = PersistenceService.shared.getLastRead()
            // Memicu animasi
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showContent = true
            }
        }
    }
}

// MARK: - Subviews

private struct HeaderView: View {
    var body: some View {
        // Tentukan apakah perangkat saat ini adalah iPad
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        VStack(spacing: 8) {
            Image("uninus") //
                .resizable()
                .scaledToFit()
                // Gunakan frame lebih besar di iPad
                .frame(height: isIPad ? 240 : 140)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            
            Text("Al-Qur'an Digital")
                // Gunakan font lebih besar di iPad
                .font(isIPad ? .system(.largeTitle, design: .rounded) : .system(.title2, design: .rounded))
                .fontWeight(.bold)
                // Beri jarak lebih besar di iPad
                .padding(.top, isIPad ? 25 : 15)
            
            Text("Kalam Ilahi dalam Genggaman Anda")
                // Gunakan font subjudul yang lebih besar di iPad
                .font(isIPad ? .title3 : .subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 30)
    }
}

private struct MenuView: View {
    @Binding var lastRead: LastRead?

    var body: some View {
        VStack(spacing: 15) {
            // ✅ SOLUSI: MenuItem dibungkus langsung dengan NavigationLink
            NavigationLink(destination: SurahListView()) {
                MenuItem(iconName: "list.bullet", title: "Daftar Surah")
            }
            .buttonStyle(.plain) // Modifier ini menghilangkan panah & menjaga style
            
            if let lastReadData = lastRead {
                NavigationLink(destination: SurahDetailView(surahNumber: lastReadData.surahNumber, surahName: lastReadData.surahName)) {
                    MenuItem(
                        iconName: "book.fill",
                        title: "Lanjutkan Membaca",
                        subtitle: "QS. \(lastReadData.surahName): \(lastReadData.ayatNumber)"
                    )
                }
                .buttonStyle(.plain)
            } else {
                MenuItem(
                    iconName: "bookmark.slash.fill",
                    title: "Lanjutkan Membaca",
                    subtitle: "Belum ada riwayat"
                )
            }
            
            NavigationLink(destination: BookmarkView()) {
                MenuItem(iconName: "star.fill", title: "Bookmark")
            }
            .buttonStyle(.plain)
            
            NavigationLink(destination: SettingsView()) {
                MenuItem(iconName: "gearshape.fill", title: "Pengaturan")
            }
            .buttonStyle(.plain)
        }
    }
}

// Desain MenuItem (Tanda panah kanan sudah dihapus dari sini)
struct MenuItem: View {
    let iconName: String
    let title: String
    var subtitle: String? = nil

    let goldGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "#D3AF37"), Color(hex: "#EFBF04")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(22.5))

                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )

                Image(systemName: iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(goldGradient)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(.thinMaterial.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        }
    }
}

// Extension untuk warna Hex (jika belum ada di file ini)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
    }
}


#Preview {
    NavigationView {
        HomeView()
            .environmentObject(AudioPlayerService())
    }
}

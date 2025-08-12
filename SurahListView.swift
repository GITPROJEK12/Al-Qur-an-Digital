import SwiftUI

// MARK: - View Model (Tidak ada perubahan)
@MainActor
class SurahListViewModel: ObservableObject {
    @Published var surahs = [Surah]()
    @Published var searchText = ""
    @Published var isLoading = true

    var filteredSurahs: [Surah] {
        if searchText.isEmpty {
            return surahs
        } else {
            return surahs.filter {
                $0.namaLatin.lowercased().contains(searchText.lowercased()) ||
                $0.arti.lowercased().contains(searchText.lowercased()) ||
                "\($0.nomor)".contains(searchText)
            }
        }
    }

    func loadSurahs() async {
        guard surahs.isEmpty else { return }
        
        do {
            surahs = try await APIService.shared.fetchAllSurahs()
            isLoading = false
        } catch {
            print("Error fetching surahs: \(error)")
            isLoading = false
        }
    }
}


// MARK: - Main View (Dengan Logika Navigasi Baru)
struct SurahListView: View {
    @StateObject private var viewModel = SurahListViewModel()

    var body: some View {
        ZStack {
            // Latar belakang gradien
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // Konten utama
            VStack {
                if viewModel.isLoading {
                    ProgressView("Memuat Surah...")
                } else {
                    List(viewModel.filteredSurahs) { surah in
                        // ✅ SOLUSI: NavigationLink dipisahkan dari tampilan baris
                        ZStack {
                            // Tampilan baris yang bisa diklik
                            SurahRow(surah: surah)
                            
                            // NavigationLink kosong yang tersembunyi
                            NavigationLink(destination: SurahDetailView(surahNumber: surah.nomor, surahName: surah.namaLatin)) {
                                EmptyView()
                            }
                            .opacity(0) // Membuatnya tidak terlihat
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Cari surat...")
        .navigationTitle("Daftar Surah")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadSurahs()
        }
    }
}


// MARK: - Row Component (Tidak ada perubahan signifikan)
struct SurahRow: View {
    let surah: Surah

    var body: some View {
        HStack(spacing: 15) {
            // Frame nomor ayat
            ZStack {
                Image("ayah")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                Text("\(surah.nomor)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            // Info surah
            VStack(alignment: .leading, spacing: 4) {
                (
                    Text(surah.namaLatin)
                        .font(.system(size: 16, weight: .bold))
                    +
                    Text("  (\(surah.nama))")
                        .font(.custom("KFGQPC Uthman Taha Naskh", size: 18))
                        .foregroundColor(.secondary)
                )
                .foregroundColor(.primary)

                Text("\(surah.arti.capitalized) • \(surah.tempatTurun.capitalized) • \(surah.jumlahAyat) ayat")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

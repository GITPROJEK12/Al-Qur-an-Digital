import SwiftUI
import UIKit // Import UIKit for UIPasteboard

struct SurahDetailView: View {
    // Properti utama
    let surahNumber: Int
    let surahName: String

    // State untuk data dari API
    @State private var surahDetail: SurahDetail?
    @State private var tafsirData: TafsirResponse?
    @State private var isLoading = true
    @State private var selectedTafsir: TafsirAyat?
    @State private var showDescriptionSheet = false
    @State private var showBismillahTafsirSheet = false // State untuk TafsirBismillahView

    // Services
    @EnvironmentObject var audioPlayer: AudioPlayerService
    @StateObject private var bookmarkService = BookmarkService.shared

    // Tambahkan environment variable untuk mendeteksi color scheme
    @Environment(\.colorScheme) var colorScheme

    // MARK: - Initializer
    init(surahNumber: Int, surahName: String) {
        self.surahNumber = surahNumber
        self.surahName = surahName
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.15)]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView("Memuat Data...")
            } else if let detail = surahDetail {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 16) {
                            HeaderInfoView(detail: detail)
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button {
                                        self.showDescriptionSheet = true
                                    } label: {
                                        Label("Lihat Deskripsi Surah", systemImage: "info.circle.fill")
                                    }
                                }

                            if detail.nomor != 9 && detail.nomor != 1 {
                                Group { // Membungkus gambar bismillah dalam Group
                                    // Mengubah gambar bismillah berdasarkan tema
                                    Image(colorScheme == .dark ? "bismillah2" : "bismillah")
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.vertical, 20) // Padding internal seperti AyatRow
                                }
                                .id("startPoint") // ID untuk bismillah
                                .background(.regularMaterial) // Latar belakang seperti AyatRow
                                .cornerRadius(20) // Sudut membulat seperti AyatRow
                                .contextMenu { // Context menu untuk bismillah
                                    Button {
                                        self.showBismillahTafsirSheet = true
                                    } label: {
                                        Label("Lihat Tafsir Pembuka", systemImage: "text.book.closed.fill")
                                    }
                                }
                            }

                            ForEach(detail.ayat) { ayat in
                                AyatRow(ayat: ayat)
                                    .id(ayat.nomorAyat) // Setiap ayat memiliki ID berdasarkan nomor ayatnya
                                    .contentShape(Rectangle())
                                    .contextMenu {
                                        contextMenuContent(for: ayat, in: detail)
                                    }
                                    .onAppear {
                                        // Simpan ayat ini sebagai ayat terakhir yang dibaca saat muncul di layar
                                        PersistenceService.shared.saveLastRead(surahNumber: detail.nomor, surahName: detail.namaLatin, ayatNumber: ayat.nomorAyat)
                                    }
                            }
                        }
                        .padding()
                        .padding(.bottom, audioPlayer.currentAyat != nil ? 100 : 0)
                    }
                    .id(surahNumber)
                    // Menggunakan sintaks onChange yang disarankan iOS 17+
                    .onChange(of: isLoading) {
                        // Pemicu pengguliran hanya setelah data dimuat
                        if !isLoading { // Akses isLoading langsung
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.spring()) {
                                    // Cek apakah ada ayat terakhir yang dibaca untuk surah ini
                                    let lastReadData = PersistenceService.shared.getLastRead()
                                    if let lastRead = lastReadData, lastRead.surahNumber == surahNumber {
                                        // Gulir ke ayat terakhir yang dibaca
                                        proxy.scrollTo(lastRead.ayatNumber, anchor: .top)
                                    } else if detail.nomor == 1 || detail.nomor == 9 {
                                        // Untuk Surah Al-Fatihah atau At-Taubah, gulir ke ayat pertama (tanpa bismillah)
                                        proxy.scrollTo(1, anchor: .top)
                                    }
                                    else {
                                        // Default gulir ke bismillah atau startPoint jika tidak ada last read atau surah berbeda
                                        proxy.scrollTo("startPoint", anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("Gagal memuat data.")
            }
        }
        .navigationTitle(surahName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if surahDetail == nil {
                await loadAllData()
            }
        }
        .sheet(item: $selectedTafsir) { tafsir in
            TafsirView(surahName: surahName, tafsirAyat: tafsir, fontSizeMultiplier: 1.0)
        }
        .sheet(isPresented: $showDescriptionSheet) {
            if let detail = surahDetail {
                SurahDescriptionView(surahName: detail.namaLatin, descriptionText: detail.deskripsi)
            }
        }
        // Sheet baru untuk TafsirBismillahView, tidak perlu lagi meneruskan konten tafsir
        .sheet(isPresented: $showBismillahTafsirSheet) {
            if let detail = surahDetail {
                TafsirBismillahView(surahName: detail.namaLatin)
            }
        }
    }

    // MARK: - Helper Functions
    @ViewBuilder
    private func contextMenuContent(for ayat: Ayat, in detail: SurahDetail) -> some View {
        Button {
            audioPlayer.startPlayback(from: ayat, in: detail.ayat, surahName: detail.namaLatin)
        } label: {
            Label("Putar dari Ayat Ini", systemImage: "play.circle.fill")
        }

        Button {
            if let tafsir = tafsirData?.tafsir.first(where: { $0.ayat == ayat.nomorAyat }) {
                self.selectedTafsir = tafsir
            }
        } label: {
            Label("Lihat Tafsir", systemImage: "text.book.closed.fill")
        }

        let isBookmarked = bookmarkService.isBookmarked(surahNumber: detail.nomor, ayatNumber: ayat.nomorAyat)
        Button {
            let bookmark = BookmarkItem(id: UUID(), surahNumber: detail.nomor, surahName: detail.namaLatin, ayatNumber: ayat.nomorAyat, ayatText: ayat.teksIndonesia)
            bookmarkService.toggleBookmark(item: bookmark)
        } label: {
            Label(isBookmarked ? "Hapus Bookmark" : "Bookmark Ayat", systemImage: isBookmarked ? "bookmark.slash" : "bookmark.fill")
        }

        // Share Ayat with filled icon
        ShareLink(item: ayat.teksArab, subject: Text("Ayat Al-Quran"), message: Text("QS. \(detail.namaLatin):\(ayat.nomorAyat)\n\n\(ayat.teksArab)\n\n\(ayat.teksIndonesia)")) {
            Label("Bagikan", systemImage: "arrow.up.square.fill")
        }

        // Copy Ayat with filled icon and full text
        Button {
            let fullAyatText = "QS. \(detail.namaLatin):\(ayat.nomorAyat)\n\n\(ayat.teksArab)\n\n\(ayat.teksIndonesia)"
            UIPasteboard.general.string = fullAyatText
        } label: {
            Label("Salin Ayat", systemImage: "doc.on.doc.fill")
        }
    }

    private func loadAllData() async {
        do {
            async let detailTask = APIService.shared.fetchSurahDetail(number: surahNumber)
            async let tafsirTask = APIService.shared.fetchTafsir(for: surahNumber)
            self.surahDetail = try await detailTask
            self.tafsirData = try await tafsirTask
            self.isLoading = false
        } catch {
            isLoading = false
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}


// MARK: - Subviews
private struct HeaderInfoView: View {
    let detail: SurahDetail
    var body: some View {
        VStack(spacing: 15) {
            Text(detail.namaLatin).font(.system(.title, design: .rounded)).fontWeight(.bold)
            Text("\(detail.arti.capitalized) • Diturunkan di \(detail.tempatTurun.capitalized)")
                .font(.subheadline).foregroundColor(.secondary)
            Text("Surat ke-\(detail.nomor) • \(detail.jumlahAyat) Ayat")
                 .font(.subheadline).foregroundColor(.secondary)
        }
        .padding().frame(maxWidth: .infinity).background(.regularMaterial).cornerRadius(20)
    }
}

struct AyatRow: View {
    let ayat: Ayat
    @AppStorage("fontSizeMultiplier") var fontSizeMultiplier: Double = 1.0
    @AppStorage("showLatinText") var showLatinText: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 15) {
                AyatNumberFrame(number: ayat.nomorAyat)
                Text(ayat.teksArab)
                    .font(.custom("KFGQPC Uthman Taha Naskh", size: 25 * fontSizeMultiplier))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(10 * fontSizeMultiplier)
            }

            if showLatinText {
                Text(ayat.teksLatin)
                    .font(.system(size: 14 * fontSizeMultiplier, weight: .regular, design: .serif))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }

            Divider()

            Text("\(ayat.nomorAyat). \(ayat.teksIndonesia)")
                .font(.system(size: 15 * fontSizeMultiplier, weight: .regular, design: .serif))
                .foregroundColor(Color.primary.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineSpacing(5 * fontSizeMultiplier)
        }
        .padding(20)
        .background(.regularMaterial)
        .cornerRadius(20)
    }
}

struct AyatNumberFrame: View {
    let number: Int
    var body: some View {
        ZStack {
            Image("ayah").resizable().scaledToFit().frame(width: 40, height: 40)
            Text("\(number)").font(.system(size: 12, weight: .bold)).foregroundColor(.primary)
        }
    }
}


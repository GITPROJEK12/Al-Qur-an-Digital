import SwiftUI

struct BookmarkView: View {
    // Mengamati perubahan pada daftar bookmark dari service
    @StateObject private var bookmarkService = BookmarkService.shared

    var body: some View {
        ZStack {
            // Latar belakang gradien yang konsisten
            LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.1), Color.blue.opacity(0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // Tampilan utama
            VStack {
                if bookmarkService.bookmarkedItems.isEmpty {
                    // Tampilan jika tidak ada bookmark
                    EmptyBookmarkView()
                } else {
                    // Tampilan jika ada bookmark
                    List {
                        ForEach(bookmarkService.bookmarkedItems) { item in
                            // ✅ SOLUSI: Menggunakan ZStack untuk menyembunyikan panah navigasi
                            ZStack {
                                BookmarkRow(item: item)
                                
                                NavigationLink(destination: SurahDetailView(surahNumber: item.surahNumber, surahName: item.surahName)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                        }
                        .onDelete(perform: bookmarkService.removeBookmark) // Fungsi swipe-to-delete
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Bookmark")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Subviews

private struct EmptyBookmarkView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .opacity(0.7)
            
            Text("Belum Ada Bookmark")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Anda bisa menandai ayat favorit dengan menekan lama pada ayat dan memilih 'Bookmark Ayat'.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// ✅ DESAIN BARU: BookmarkRow dibuat mirip seperti SurahRow
private struct BookmarkRow: View {
    let item: BookmarkItem

    var body: some View {
        HStack(spacing: 15) {
            // Frame ikon, mirip dengan frame nomor ayat di daftar surah
            ZStack {
                
                Image(systemName: "star.fill") // Ikon bintang untuk penanda bookmark
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.yellow)
            }
            
            // Info surah dan ayat
            VStack(alignment: .leading, spacing: 4) {
                Text("QS. \(item.surahName): \(item.ayatNumber)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                Text(item.ayatText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
                    .lineLimit(1) // Tampilkan hanya 1 baris agar rapi
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.regularMaterial)
        .cornerRadius(16)
    }
}

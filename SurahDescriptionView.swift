import SwiftUI

struct SurahDescriptionView: View {
    let surahName: String
    let descriptionText: String
    
    // Lingkungan untuk menutup sheet
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Deskripsi Surah \(surahName)")
                        .font(.title2.bold())
                        .padding(.bottom, 10)
                    
                    // ✅ MEMANGGIL FUNGSI LOKAL
                    Text(strippingHTML(from: descriptionText))
                        .font(.system(.body, design: .serif))
                        .lineSpacing(8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // ✅ SOLUSI: Fungsi dipindahkan langsung ke dalam view ini
    private func strippingHTML(from string: String) -> String {
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}

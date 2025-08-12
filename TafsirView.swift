import SwiftUI

struct TafsirView: View {
    let surahName: String
    let tafsirAyat: TafsirAyat
    
    // Add this property to receive the font size multiplier
    let fontSizeMultiplier: Double

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tafsir QS. \(surahName): \(tafsirAyat.ayat)")
                        .font(.title2.bold())
                        .padding(.bottom, 10)
                    
                    Text(tafsirAyat.teks)
                        .font(.system(size: 17 * fontSizeMultiplier, weight: .regular, design: .serif)) // Apply multiplier here
                        .lineSpacing(8 * fontSizeMultiplier) // Also adjust line spacing
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
}

import SwiftUI

struct TafsirBismillahView: View {
    let surahName: String
    
    // Konten tafsir bismillah dipindahkan ke sini sebagai properti statis
    static let bismillahTafsir: String = """
    "Bismillahirrahmanirrahim" (Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang) adalah kalimat pembuka yang agung dalam Islam. Maknanya sangat luas, mencakup:
    1.  **Tabarruk (Mengharap Berkah)**: Memulai segala sesuatu dengan nama Allah untuk mengharap keberkahan dan pertolongan-Nya.
    2.  **Istia'nah (Meminta Pertolongan)**: Menunjukkan bahwa setiap perbuatan dilakukan atas kekuasaan dan pertolongan Allah semata.
    3.  **Pengakuan Keagungan Allah**: Mengagungkan Allah sebagai penguasa alam semesta yang memiliki sifat Ar-Rahman (Maha Pengasih kepada semua makhluk) dan Ar-Rahim (Maha Penyayang khusus bagi orang beriman).
    4.  **Kesadaran Diri**: Mengingatkan bahwa manusia tidak memiliki kemampuan apa pun tanpa kehendak dan kekuasaan Allah.
    """

    @Environment(\.dismiss) var dismiss // Untuk menutup sheet

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Tafsir Pembuka Surah \(surahName)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)

                    // Menggunakan properti statis untuk menampilkan tafsir
                    Text(TafsirBismillahView.bismillahTafsir)
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundColor(.primary)
                }
                .padding()
            }
            .navigationTitle("Tafsir Basmalah")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Tutup") {
                        dismiss()
                    }
                }
            }
        }
    }
}

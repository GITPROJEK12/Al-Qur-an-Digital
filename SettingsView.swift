import SwiftUI

struct SettingsView: View {
    @AppStorage("appColorScheme") var appColorScheme: Int = 0
    @AppStorage("showLatinText") var showLatinText: Bool = true
    let qariOptions: [String: String] = [
        "01": "Mishary Rashid Alafasy",
        "02": "Abdul Basit Abdus Samad",
        "03": "Abdurrahman As-Sudais",
        "04": "Maher Al-Muaiqly",
        "05": "Muhammad Thaha Al-Junaid",
    ]
    @AppStorage("selectedQari") var selectedQariId: String = "05"
    @AppStorage("fontSizeMultiplier") var fontSizeMultiplier: Double = 1.0

    var body: some View {
        Form {
            // MARK: - Pengaturan Tampilan
            Section(header: Text("Pengaturan Tampilan")) {
                Picker("Tema Aplikasi", selection: $appColorScheme) {
                    Text("Sistem").tag(0)
                    Text("Terang").tag(1)
                    Text("Gelap").tag(2)
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading) {
                    Text("Ukuran Font Arab & Terjemahan (\(String(format: "%.1f", fontSizeMultiplier))x)")
                    Slider(value: $fontSizeMultiplier, in: 0.8...1.5, step: 0.1)
                }
                Toggle("Tampilkan Teks Latin", isOn: $showLatinText)
            }

            // MARK: - Pengaturan Audio
            Section(header: Text("Pengaturan Audio")) {
                Picker("Pilihan Qari", selection: $selectedQariId) {
                    ForEach(qariOptions.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                        Text(value).tag(key)
                    }
                }
            }

            // MARK: - Tentang Aplikasi
            Section(header: Text("Tentang Aplikasi")) {
                HStack {
                    Text("Versi Aplikasi")
                    Spacer()
                    Text("1.0.0")
                }
                HStack {
                    Text("Pengembang")
                    Spacer()
                    Text("MUHAMAD ALVIANSYAH")
                }
            }
        }
        .navigationTitle("Pengaturan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}

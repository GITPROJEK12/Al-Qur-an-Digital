import Foundation

// MARK: - Model untuk Daftar Surah
struct Surah: Codable, Identifiable {
    let id = UUID()
    let nomor: Int
    let nama: String
    let namaLatin: String
    let jumlahAyat: Int
    let tempatTurun: String
    let arti: String
    
    enum CodingKeys: String, CodingKey {
        case nomor, nama, namaLatin, jumlahAyat, tempatTurun, arti
    }
}

// MARK: - Model untuk Detail Surah
// ✅ SOLUSI: Tambahkan 'Equatable' di sini
struct SurahDetail: Codable, Equatable {
    let nomor: Int
    let nama: String
    let namaLatin: String
    let jumlahAyat: Int
    let tempatTurun: String
    let arti: String
    let deskripsi: String
    let audioFull: [String: String]
    let ayat: [Ayat]
}

// MARK: - Model untuk Ayat
struct Ayat: Codable, Identifiable, Equatable, Hashable {
    let id = UUID()
    let nomorAyat: Int
    let teksArab: String
    let teksLatin: String
    let teksIndonesia: String
    let audio: [String: String]?
    
    static func == (lhs: Ayat, rhs: Ayat) -> Bool {
        return lhs.nomorAyat == rhs.nomorAyat && lhs.teksArab == rhs.teksArab
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nomorAyat)
    }
    
    enum CodingKeys: String, CodingKey {
        case nomorAyat, teksArab, teksLatin, teksIndonesia, audio
    }
}
// MARK: - Model untuk Data Tafsir
struct TafsirResponse: Codable {
    let tafsir: [TafsirAyat]
}

struct TafsirAyat: Codable, Identifiable {
    let id = UUID()
    let ayat: Int
    let teks: String
    
    enum CodingKeys: String, CodingKey {
        case ayat, teks
    }
}

// MARK: - Model Lainnya
struct LastRead: Codable {
    let surahNumber: Int
    let surahName: String
    let ayatNumber: Int
}

// Wrapper untuk Response API
struct APIResponse<T: Codable>: Codable {
    let code: Int
    let message: String
    let data: T
}

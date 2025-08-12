import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    private init() {}

    private let baseURL = "https://equran.id/api/v2"

    func fetchAllSurahs() async throws -> [Surah] {
        guard let url = URL(string: "\(baseURL)/surat") else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }
        let apiResponse = try JSONDecoder().decode(APIResponse<[Surah]>.self, from: data)
        return apiResponse.data
    }

    func fetchSurahDetail(number: Int) async throws -> SurahDetail {
        guard let url = URL(string: "\(baseURL)/surat/\(number)") else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { throw URLError(.badServerResponse) }
        let apiResponse = try JSONDecoder().decode(APIResponse<SurahDetail>.self, from: data)
        return apiResponse.data
    }
    func fetchTafsir(for surahNumber: Int) async throws -> TafsirResponse {
        guard let url = URL(string: "https://equran.id/api/v2/tafsir/\(surahNumber)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let apiResponse = try JSONDecoder().decode(APIResponse<TafsirResponse>.self, from: data)
        return apiResponse.data
    }
}

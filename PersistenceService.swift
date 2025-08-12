import Foundation

class PersistenceService {
    static let shared = PersistenceService()
    private let lastReadKey = "lastReadLocation"
    private let userDefaults = UserDefaults.standard

    func saveLastRead(surahNumber: Int, surahName: String, ayatNumber: Int) {
        let lastReadData = LastRead(surahNumber: surahNumber, surahName: surahName, ayatNumber: ayatNumber)
        if let encodedData = try? JSONEncoder().encode(lastReadData) {
            userDefaults.set(encodedData, forKey: lastReadKey)
        }
    }

    func getLastRead() -> LastRead? {
        if let savedData = userDefaults.object(forKey: lastReadKey) as? Data {
            return try? JSONDecoder().decode(LastRead.self, from: savedData)
        }
        return nil
    }
}

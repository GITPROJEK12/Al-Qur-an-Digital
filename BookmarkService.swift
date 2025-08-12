//
//  BookmarkService.swift
//  QuranDigital
//
//  Created by MUHAMAD ALVIANSYAH on 09/07/25.
//

import Foundation


struct BookmarkItem: Codable, Identifiable, Hashable {
    let id: UUID
    let surahNumber: Int
    let surahName: String
    let ayatNumber: Int
    let ayatText: String
}


class BookmarkService: ObservableObject {
    static let shared = BookmarkService()
    
    @Published var bookmarkedItems: [BookmarkItem] = []
    
    private let bookmarksKey = "savedBookmarks"
    
    init() {
        
        self.bookmarkedItems = fetchBookmarks()
    }
    // Cek apakah sebuah ayat sudah di-bookmark
    func isBookmarked(surahNumber: Int, ayatNumber: Int) -> Bool {
        bookmarkedItems.contains { $0.surahNumber == surahNumber && $0.ayatNumber == ayatNumber }
    }
    
    // Tambah atau hapus bookmark
    func toggleBookmark(item: BookmarkItem) {
        if isBookmarked(surahNumber: item.surahNumber, ayatNumber: item.ayatNumber) {
            
            bookmarkedItems.removeAll { $0.surahNumber == item.surahNumber && $0.ayatNumber == item.ayatNumber }
        } else {
            
            bookmarkedItems.append(item)
        }
        saveBookmarks()
    }
    func removeBookmark(at offsets: IndexSet) {
        bookmarkedItems.remove(atOffsets: offsets)
        saveBookmarks()
    }
    
    // Mengambil data dari UserDefaults
    private func fetchBookmarks() -> [BookmarkItem] {
        guard let data = UserDefaults.standard.data(forKey: bookmarksKey) else { return [] }
        
        do {
            return try JSONDecoder().decode([BookmarkItem].self, from: data)
        } catch {
            print("Error decoding bookmarks: \(error)")
            return []
        }
    }
    
    // Menyimpan data ke UserDefaults
    private func saveBookmarks() {
        do {
            let data = try JSONEncoder().encode(bookmarkedItems)
            UserDefaults.standard.set(data, forKey: bookmarksKey)
        } catch {
            print("Error encoding bookmarks: \(error)")
        }
    }
}

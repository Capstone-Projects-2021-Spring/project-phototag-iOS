//
//  Search.swift
//  PhotoTag
//
//  Created by Sebastian Tota on 4/7/21.
//

import Foundation

class Search {
    
    static let ignoreTerms: [String] = ["show me", "show", "photos of", "photos", "a photo"]
    static let delimiters: [String] = [",", "and"]
    
    static func splitTeremsOnDelim(text: String) -> [String] {
        var res: [String] = [text]
        for delim in delimiters {
            res = res.map { $0.components(separatedBy: delim)}.flatMap { $0 }
        }
        return res
    }
    
    static func removeIgnoreTerms(text: String) -> String {
        var text = text
        for term in ignoreTerms {
            text = text.replacingOccurrences(of: " \(term) ", with: " ")
        }
        return text
    }
    
    static func termContains(tags: [String], term: String) -> Bool {
        for tag in tags {
            if tag.hasPrefix(term) {
                return true
            }
        }
        return false
    }
    
    static func getTagsFromText(searchText: String, tags: [String]) -> [String] {
        var searchText = " \(searchText.trimmingCharacters(in: .whitespacesAndNewlines)) "
        searchText = removeIgnoreTerms(text: searchText)

        let roughSplit = splitTeremsOnDelim(text: searchText)
        
        var resTags: [String] = []
        
        for split in roughSplit {
            let split: String = split.trimmingCharacters(in: .whitespacesAndNewlines)
            let words: [String] = split.components(separatedBy: " ")
            var termBuilder: String = ""
            
            var i = 0
            while i < words.count {
                let word = words[i]
                
                let tempTerm = "\(termBuilder) \(word)".trimmingCharacters(in: .whitespacesAndNewlines)
                if termContains(tags: tags, term: tempTerm) {
                    termBuilder = tempTerm
                } else {
                    if termBuilder == "" {
                        print("Search: Not a valid tag: \(word)")
                    } else {
                        print("Search: Found term: \(termBuilder)")
                        
                        if tags.contains(termBuilder) {
                            resTags.append(termBuilder)
                            i -= 1
                        }
                    }
                    termBuilder = ""
                }
                i += 1
            }
            if termBuilder != "" && tags.contains(termBuilder) {
                resTags.append(termBuilder)
            }
        }
        return resTags
    }
    
}

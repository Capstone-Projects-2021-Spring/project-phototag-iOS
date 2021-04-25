//
//  PhotoTagUnitTests.swift
//  PhotoTagUnitTests
//
//  Created by Seb Tota on 4/24/21.
//

import XCTest
import Photos
import Foundation
import Firebase
@testable import PhotoTag

class PhotoTagUnitTests: XCTestCase {
    
    let ref: DatabaseReference = Database.database().reference().ref.child("iOS/unitTest/Photos/(null)||-|L0||-|001")

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFirebaseKeyEncoding() throws {
        let str: String = "abc/abc#abc$abc[abc]abc.abc"
        let expectedEncStr = "abc||-|abc--|-abc-|--abc|---abc|--|abc---|abc"
        let encStr = Photo.firebaseEncodeString(str: str)
        XCTAssertTrue(encStr == expectedEncStr)
    }
    
    func resetUnitTestPhotoDbObject() {
        // Reset unit test photo object in db
        ref.removeValue()
    }
    
    func testGetTags() throws {
        resetUnitTestPhotoDbObject()
        ref.child("photo_tags/testTag1").setValue(true)
        ref.child("photo_tags/testTag2").setValue(true)
        
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {
            
            var retreivedTags: [String] = []
            
            self.ref.child("photo_tags").getData { (error, snapshot) in
                if let error = error {
                    print("Error updating tags from the database: Error: \(error)")
                } else if snapshot.exists() {
                    for child in snapshot.children {
                        let childTag = child as! DataSnapshot
                        let tag = childTag.key
                        retreivedTags.append(tag)
                    }
                    
                    XCTAssertTrue(retreivedTags.contains("testTag1"))
                    XCTAssertTrue(retreivedTags.contains("testTag2"))
                }
            }
        }
        XCTAssertNotNil(photo)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

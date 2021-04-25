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

let testSemaphore = DispatchSemaphore(value: 1)


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
    
    func getAllTagsAssociatedWithUnitTestPhotoObj(callback: @escaping ([String]) -> ()) {
        self.ref.child("photo_tags").getData { (error, snapshot) in
            var retreivedTags: [String] = []
            XCTAssertFalse(error != nil)
            XCTAssertTrue(snapshot.exists())
            
            if snapshot.exists() {
                for child in snapshot.children {
                    let childTag = child as! DataSnapshot
                    let tag = childTag.key
                    retreivedTags.append(tag)
                }
                
                callback(retreivedTags)
            }
        }
    }
    
    func testGetTags() throws {
        testSemaphore.wait()
        resetUnitTestPhotoDbObject()
        ref.child("photo_tags/testTag1").setValue(true)
        ref.child("photo_tags/testTag2").setValue(true)
        
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {
            self.getAllTagsAssociatedWithUnitTestPhotoObj { (tags: [String]) in
                XCTAssertTrue(tags.contains("testTag1"))
                XCTAssertTrue(tags.contains("testTag2"))
                testSemaphore.signal()
            }
        }
        XCTAssertNotNil(photo)
    }
    
    func testAddTag() throws {
        testSemaphore.wait()
        resetUnitTestPhotoDbObject()  // Reset test object in db
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {}
        XCTAssertNotNil(photo)
        
        // Add a new tag
        photo.addTag(tag: "testTag1")

        // Make sure new tag was added
        self.getAllTagsAssociatedWithUnitTestPhotoObj { (tags: [String]) in
            XCTAssertTrue(tags.contains("testTag1"))
            testSemaphore.signal()
        }
    }

}

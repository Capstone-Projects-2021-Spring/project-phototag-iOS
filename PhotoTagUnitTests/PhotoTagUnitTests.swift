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
            }
            callback(retreivedTags)
        }
    }
    
    func testGetTags() throws {
        resetUnitTestPhotoDbObject()
        ref.child("photo_tags/testtag1").setValue(true)
        ref.child("photo_tags/testtag2").setValue(true)
        
        let testAsset: PHAsset = PHAsset.init()
        let asyncExpectation = expectation(description: "Async block executed")
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {
            self.getAllTagsAssociatedWithUnitTestPhotoObj { (tags: [String]) in
                XCTAssertTrue(tags.contains("testtag1"))
                XCTAssertTrue(tags.contains("testtag2"))
                asyncExpectation.fulfill()
            }
        }
        XCTAssertNotNil(photo)
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testAddTag() throws {
        resetUnitTestPhotoDbObject()  // Reset test object in db
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {}
        XCTAssertNotNil(photo)
        
        // Add a new tag
        XCTAssertTrue(photo.addTag(tag: "testtag1"))

        // Make sure new tag was added
        let asyncExpectation = expectation(description: "Async block executed")
        self.getAllTagsAssociatedWithUnitTestPhotoObj { (tags: [String]) in
            XCTAssertTrue(tags.contains("testtag1"))
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testRemoveTag() throws {
        resetUnitTestPhotoDbObject()  // Reset test object in db
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {}
        XCTAssertNotNil(photo)
        
        // Add a new tag
        ref.child("photo_tags/testTag1").setValue(true)
        
        // Test remove tag function
        photo.removeTag(tag: "testTag1")

        // Make sure new tag was added
        let asyncExpectation = expectation(description: "Async block executed")
        self.getAllTagsAssociatedWithUnitTestPhotoObj { (tags: [String]) in
            XCTAssertFalse(tags.contains("testtag1"))
            asyncExpectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testMarkTagged() throws {
        resetUnitTestPhotoDbObject()  // Reset test object in db
        let testAsset: PHAsset = PHAsset.init()
        let photo: Photo = Photo(asset: testAsset, username: "unitTest") {}
        XCTAssertNotNil(photo)

        // Mark photo as tagged
        photo.markTagged()

        // Make sure photo was tagged and being auto tagged
        let asyncExpectation = expectation(description: "Async block executed")
        self.ref.getData { (error, snapshot) in
            XCTAssertFalse(error != nil)
            XCTAssertTrue(snapshot.exists())

            if snapshot.exists() {
                if snapshot.hasChild("auto_tagged") {
                    let dbTagged: Bool = snapshot.childSnapshot(forPath: "auto_tagged").value! as! Bool
                    XCTAssertTrue(dbTagged)
                    asyncExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

}

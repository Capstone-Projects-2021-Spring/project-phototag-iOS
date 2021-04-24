//
//  PhotoTagUnitTests.swift
//  PhotoTagUnitTests
//
//  Created by Seb Tota on 4/24/21.
//

import XCTest
@testable import PhotoTag

class PhotoTagUnitTests: XCTestCase {

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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}

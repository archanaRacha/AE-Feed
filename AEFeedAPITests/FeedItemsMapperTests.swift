//
//  FeedItemsMapperTests.swift
//  AEFeedAPITests
//
//  Created by archana racha on 19/12/24.
//

import XCTest
import AEFeedAPI
import AE_Feed

class FeedItemsMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon200HTTPResponse() throws {
            let json = makeItemsJSON([])
            let samples = [199, 201, 300, 400, 500]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(data: json, from: HTTPURLResponse(statusCode: code))
            )}
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
            let invalidJSON = Data("invalid json".utf8)

            XCTAssertThrowsError(
                try FeedItemsMapper.map(data: invalidJSON, from: HTTPURLResponse(statusCode: 200))
            )
    }

    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
            let emptyListJSON = makeItemsJSON([])
        let result = try FeedItemsMapper.map(data: emptyListJSON, from: HTTPURLResponse(statusCode: 200))

               XCTAssertEqual(result, [])
    }
    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "http://a-url.com")!)
       
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
       
        
        let json = makeItemsJSON([item1.json, item2.json])

        let result = try FeedItemsMapper.map(data: json, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, [item1.model, item2.model])

    }
  
    
    // MARK: helpers

  
    private func makeItem(id:UUID,description:String? = nil,location:String? = nil,imageURL:URL) -> (model:FeedImage,json:[String:Any]){
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id" : id.uuidString,
            "description" : description,
            "location" : location,
            "image" : imageURL.absoluteString
        ].compactMapValues{$0}
        return (item,json)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


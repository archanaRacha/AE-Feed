//
//  RemoteFeedLoaderTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 10/02/24.
//

import XCTest
import AE_Feed
final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let (_,client) = makeSUT(url:URL.init(string: "https://a-url.com")!)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_requestsDataFromURL(){
        let url = URL.init(string: "https:a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load()
        sut.load()
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        
        var capturedErrors = [RemoteFeedLoader.Error]()
        sut.load {
            capturedErrors.append($0)
        }
        let clientError = NSError(domain: "Test", code: 0)
        client.completions[0](clientError)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }

    // MARK: helpers
    private func makeSUT(url: URL = URL.init(string: "https://a-url.com")!) -> (sut:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        return(sut, client)
    }
    private class HTTPClientSpy:HTTPClient{
        var requestedURLs : [URL] = []

        var completions = [(Error)->Void]()
        func get(from url:URL,completion:@escaping(Error)->Void){

            completions.append(completion)
            requestedURLs.append(url)
        }
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

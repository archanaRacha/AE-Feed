//
//  RemoteLoaderTests.swift
//  AEFeedAPITests
//
//  Created by archana racha on 18/12/24.
//

import XCTest
import AE_Feed
import AEFeedAPI
final class RemoteLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL(){
        let (_,client) = makeSUT(url:URL.init(string: "https://a-url.com")!)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    func test_load_requestsDataFromURL(){
        let url = URL.init(string: "https:a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load{_ in }

        XCTAssertEqual(client.requestedURLs,[url])
    }
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = URL.init(string: "https:a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load{_ in }
        sut.load{_ in }
        XCTAssertEqual(client.requestedURLs,[url,url])
    }
    func test_load_deliversErrorOnClientError(){
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWith: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with :clientError)
        }
    }
    
    func test_load_deliversErrorOnMapperError() {
       let (sut, client) = makeSUT(mapper: { _, _ in
           throw anyNSError()
       })
    expect(sut, toCompleteWith: failure(.invalidData), when: {
        client.complete(withStatusCode: 200, data: anyData())
       })
    }
    func test_load_deliversMappedResource() {
            let resource = "a resource"
            let (sut, client) = makeSUT(mapper: { data, _ in
                String(data: data, encoding: .utf8)!
            })
        expect(sut, toCompleteWith: .success(resource), when: {
            client.complete(withStatusCode: 200, data: Data(resource.utf8))
        })
    }

    func test_load_doesNotDeliverResultAfterSUTInstnceHasBeenDeallocated(){
        let url = URL(string:"http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteLoader<String>? = RemoteLoader<String>(url: url, client: client, mapper: { _, _ in "any" })
        var capturedResults = [RemoteLoader<String>.Result]()
        sut?.load(completion: { capturedResults.append($0)
        })
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: helpers
    private func makeSUT(
           url: URL = URL(string: "https://a-url.com")!,
           mapper: @escaping RemoteLoader<String>.Mapper = { _, _ in "any" },
           file: StaticString = #file,
           line: UInt = #line
       ) -> (sut: RemoteLoader<String>, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
           let sut = RemoteLoader<String>(url: url, client: client, mapper: mapper)
        trackMemoryLeaks(sut,file:file,line:line)
        trackMemoryLeaks(client,file:file,line:line)
        return(sut, client)
    }
    private func failure(_ error: RemoteLoader<String>.Error) -> RemoteLoader<String>.Result {
        return .failure(error)
    }
  
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
    private func makeItemsJson(_ items :[[String:Any]])-> Data{
        let itemsJSON = ["items": items]
        return try! JSONSerialization.data(withJSONObject: itemsJSON, options: .prettyPrinted)
    }
    private func expect(_ sut: RemoteLoader<String>, toCompleteWith expectedResult: RemoteLoader<String>.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for laod completion")
        sut.load { receivedResult in
            switch (receivedResult,expectedResult){
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            case let (.failure(receivedError as RemoteLoader<String>.Error), .failure(expectedError as RemoteLoader<String>.Error)):
                XCTAssertEqual(receivedError, expectedError,file:file,line: line)
            default:
                XCTFail("Expected reslt \(expectedResult) got \(receivedResult) instead",file:file,line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
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

//
//  RemoteFeedLoaderTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 10/02/24.
//

import XCTest
import AE_Feed
final class LoadFeedFromRemoteUseCaseTests: XCTestCase {

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
        expect(sut: sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with :clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse(){
        let (sut, client) = makeSUT()
        
    let samples = [199,201,300,400,500]
        samples.enumerated().forEach { index,code in
            expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJson([])
                client.complete(withStatusCode :code, data: json,index: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON(){
        let (sut, client)  = makeSUT()
        expect(sut: sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJSON = Data.init("invalid json".utf8)
            client.complete(withStatusCode: 200,data:invalidJSON)
        }
    }

    func test_load_deliverNoItemsOn200HTTPResponseWithEmptyList(){
        let (sut, client)  = makeSUT()
        expect(sut: sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemsJson([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        }

    }
    func test_load_deliverItemsOn200HTTPResponseWithJsonItems(){
        let (sut, client)  = makeSUT()
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "http://a-url.com")!)
       
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "http://another-url.com")!)
       
        
        let items = [item1.model,item2.model]
        expect(sut: sut, toCompleteWithResult: .success(items)) {
            let json = makeItemsJson([item1.json,item2.json])
            client.complete(withStatusCode: 200, data: json)
        }

    }
    func test_load_doesNotDeliverResultAfterSUTInstnceHasBeenDeallocated(){
        let url = URL(string:"http://any-url.com")!
        let client = HTTPClientSpy()
        var sut:RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load(completion: { capturedResults.append($0)
        })
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJson([]))
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: helpers
    private func makeSUT(url: URL = URL.init(string: "https://a-url.com")!,file: StaticString = #file ,line:UInt = #line) -> (sut:RemoteFeedLoader,client:HTTPClientSpy){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackMemoryLeaks(sut,file:file,line:line)
        trackMemoryLeaks(client,file:file,line:line)
        return(sut, client)
    }
    private func failure(_ error:RemoteFeedLoader.Error) -> RemoteFeedLoader.Result{
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
    private func expect(sut: RemoteFeedLoader,toCompleteWithResult expectedResult:RemoteFeedLoader.Result, when action:()->Void, file:StaticString = #file,line:UInt = #line){
        let exp = expectation(description: "Wait for laod completion")
        sut.load { receivedResult in
            switch (receivedResult,expectedResult){
            case let(.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems,file:file,line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError,file:file,line: line)
            default:
                XCTFail("Expected reslt \(expectedResult) got \(receivedResult) instead",file:file,line: line)
            }
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    private class HTTPClientSpy:HTTPClient{
        
        private var messages = [(url:URL, completion:(HTTPClientResult)->Void)]()
        var requestedURLs:[URL] {
            return messages.map{$0.url}
        }
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url,completion))
        }
        func complete(with error:Error, at index:Int = 0){
            messages[index].completion(.failure(error))
        }
        func complete(withStatusCode code:Int, data:Data,index:Int = 0){
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data,response))
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

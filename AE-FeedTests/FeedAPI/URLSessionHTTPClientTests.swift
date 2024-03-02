//
//  URLSessionHTTPClienTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 28/02/24.
//

import XCTest
import AE_Feed
protocol HTTPSession{
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask
}
protocol HTTPSessionDataTask{
    func resume()
}
class URLSessionHTTPClient {
    private let session:HTTPSession
    init(session:HTTPSession){
        self.session = session
    }
    func get(from url:URL, completion : @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error{
                completion(HTTPClientResult.failure(error ))
            }
            
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string:"http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url:url,task:task)
        let sut = URLSessionHTTPClient(session:session)
        sut.get(from:url) { _ in }
        XCTAssertEqual(task.resumeCount, 1)
    }
    func test_getFromURL_failsOnRequestsError() {
        let url = URL(string:"http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        let session = URLSessionSpy()
        session.stub(url:url, error: error)
        let sut = URLSessionHTTPClient(session:session)
        let exp = expectation(description: "wait for complete")
        sut.get(from:url) { result  in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with \(error), got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    //MARK: Helpers
    private class URLSessionSpy : HTTPSession {
        
        private struct Stub{
            let task : HTTPSessionDataTask?
            let error : NSError?
        }
        private var stubs = [URL:Stub]()
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionDataTask {
            guard let stub = stubs[url] else{
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil,nil,stubs[url]?.error)
            return stubs[url]?.task ?? FakeURLSessionDataTask()// data task
        }
        func stub(url:URL,task:HTTPSessionDataTask? =  nil,error:NSError? = nil){
            stubs[url] = Stub.init(task: task, error: error)
        }
    }
    
    private class FakeURLSessionDataTask : HTTPSessionDataTask{
         func resume() {}
    }
    private class URLSessionDataTaskSpy: HTTPSessionDataTask{
        var resumeCount = 0
         func resume() {
            resumeCount += 1
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

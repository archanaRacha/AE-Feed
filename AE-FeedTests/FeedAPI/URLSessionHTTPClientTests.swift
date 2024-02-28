//
//  URLSessionHTTPClienTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 28/02/24.
//

import XCTest

class URLSessionHTTPClient {
    private let session:URLSession
    init(session:URLSession){
        self.session = session
    }
    func get(from url:URL) {
        session.dataTask(with: url) { _, _, _ in }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string:"http://any-url.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url:url,task:task)
        let sut = URLSessionHTTPClient(session:session)
        sut.get(from:url)
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    //MARK: Helpers
    private class URLSessionSpy : URLSession {

        private var stubs = [URL:URLSessionDataTask]()
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            return stubs[url] ?? FakeURLSessionDataTask()// data task
        }
        func stub(url:URL,task:URLSessionDataTask){
            stubs[url] = task
        }
    }
    
    private class FakeURLSessionDataTask : URLSessionDataTask{
        override func resume() {}
    }
    private class URLSessionDataTaskSpy: URLSessionDataTask{
        var resumeCount = 0
        override func resume() {
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

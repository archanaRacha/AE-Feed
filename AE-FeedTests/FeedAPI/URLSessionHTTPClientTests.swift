//
//  URLSessionHTTPClienTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 28/02/24.
//

import XCTest
import AE_Feed

class URLSessionHTTPClient {
    private let session:URLSession
    init(session:URLSession = .shared){
        self.session = session
    }
    func get(from url:URL, completion : @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error{
                completion(.failure(error ))
            }
            
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {

    func test_getFromURL_failsOnRequestsError() {
        URLProtocolStub.startIntercepting()
        let url = URL(string:"http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
       
        URLProtocolStub.stub(url:url,data:nil,response:nil, error: error)
        let sut = URLSessionHTTPClient()
        let exp = expectation(description: "wait for complete")
        sut.get(from:url) { result  in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
                
            default:
                XCTFail("Expected failure with \(error), got \(result) instead.")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        URLProtocolStub.stopIntercepting()
    }
    //MARK: Helpers
    private class URLProtocolStub : URLProtocol {
        
        private struct Stub{
            let data: Data?
            let response:URLResponse?
            let error : NSError?
        }
        private static var stubs = [URL:Stub]()
       
        static func stub(url:URL,data: Data?, response:URLResponse?,error:NSError){
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        static func startIntercepting(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopIntercepting(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {return false}
            return URLProtocolStub.stubs[url] != nil
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        override func startLoading() {
            guard let url = request.url , let stub = URLProtocolStub.stubs[url] else {return}
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = stub.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() {}
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

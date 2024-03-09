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
    struct UnexpectedValueRepresentation:Error{}
    func get(from url:URL, completion : @escaping(HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error{
                completion(.failure(error ))
            }else if let data = data, data.count > 0 , let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            }else{
                completion(.failure(UnexpectedValueRepresentation()))
            }
            
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performGETRequestwithURL(){
        let url = anyURL()
        let exp = expectation(description: "wait for request")
        URLProtocolStub.observeRequests{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        makeSUT().get(from: url) { _ in
        }
        wait(for: [exp], timeout: 1.0)
        
    }
    func test_getFromURL_failsOnRequestsError() {
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as? NSError
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: httpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: httpURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
       
    }
    func test_getFroURL_succeedOnHTTPURLResponseWithData(){
        let response = httpURLResponse()
        let data = anyData()
        URLProtocolStub.stub(data:data,response:response, error: nil)
        let exp = expectation(description: "wait for complete")

        makeSUT().get(from:anyURL()) { result  in
            switch result {
            case let .success(receivedData, receivedResponse):
                XCTAssertEqual(receivedData,data )
                XCTAssertEqual(receivedResponse.url,response.url)
                XCTAssertEqual(receivedResponse.statusCode,response.statusCode)
                break
            case let .failure(_ as NSError): break
    
            default:
               break
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    
    }
    //MARK: Helpers
    private func makeSUT(file:StaticString = #file,line :UInt = #line) ->URLSessionHTTPClient{
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut,file:file,line:line)
        return sut
    }
    private func resultErrorFor(data:Data?,response:URLResponse?,error:Error?,file:StaticString = #file,line :UInt = #line) -> Error?{
        URLProtocolStub.stub(data:data,response:response, error: error as NSError?)
        let exp = expectation(description: "wait for complete")
        var receivedError : Error?
        makeSUT().get(from:anyURL()) { result  in
            switch result {
            case let .failure(error as NSError):
                receivedError = error
            default:
                XCTFail("Expected failure with \(error), got \(result) instead.",file:file,line:line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }
    private func anyData() -> Data{
        return Data(bytes:"any data".utf8)
    }
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    private func httpURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    private class URLProtocolStub : URLProtocol {
        
        private struct Stub{
            let data: Data?
            let response:URLResponse?
            let error : NSError?
        }
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest)->Void)?
        
        static func stub(data: Data?, response:URLResponse?,error:NSError?){
            stub = Stub(data: data, response: response, error: error)
        }
        static func observeRequests(observer:@escaping(URLRequest)->Void){
            requestObserver = observer
        }
        static func startIntercepting(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopIntercepting(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response{
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error{
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        override func stopLoading() {}
    }
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLProtocolStub.startIntercepting()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocolStub.stopIntercepting()
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

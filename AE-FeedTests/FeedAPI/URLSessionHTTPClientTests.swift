//
//  URLSessionHTTPClienTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 28/02/24.
//

import XCTest
import AE_Feed


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
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as? NSError
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler : { $0.cancel() }) as NSError?
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: httpURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: httpURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
       
    }
    func test_getFroURL_succeedWithEmptyDataOnHTTPURLResponseWithNilData(){
        let response = httpURLResponse()
        let receivedValues = resultValuesFor((data: nil, response:response , error: nil))
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data,emptyData)
        XCTAssertEqual(receivedValues?.response.url,response.url)
        XCTAssertEqual(receivedValues?.response.statusCode,response.statusCode)
        
    
    }
    
    func test_getFroURL_succeedOnHTTPURLResponseWithData(){
        let response = httpURLResponse()
        let receivedValues =  resultValuesFor((data: nil, response:response , error: nil))
        XCTAssertEqual(receivedValues?.data,Data())
        XCTAssertEqual(receivedValues?.response.url,response.url)
        XCTAssertEqual(receivedValues?.response.statusCode,response.statusCode)

    }
    //MARK: Helpers
    private func makeSUT(file:StaticString = #file,line :UInt = #line) ->HTTPClient{
        let sut = URLSessionHTTPClient()
        trackMemoryLeaks(sut,file:file,line:line)
        return sut
    }
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
            values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT(file:file,line:line)
        let exp = expectation(description: "wait for complete")
        var receivedResult : HTTPClient.Result!
        taskHandler( sut.get(from:anyURL()) { result  in
            receivedResult = result
            exp.fulfill()
        })
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    private func resultErrorFor(_ values:(data:Data?,response:URLResponse?,error:Error?)? = nil,taskHandler : (HTTPClientTask)->Void = {_ in },file:StaticString = #file,line :UInt = #line) -> Error?{
        let result = resultFor(values,taskHandler:taskHandler,file: file, line:line)
        switch result {
        case .failure(let error):
            return error
        default:
            XCTFail("Expected failure with, got \(result) instead.",file:file,line:line)
            return nil
        }
       
    }
    private func resultValuesFor(_ values:(data:Data?,response:URLResponse?,error:Error?),file:StaticString = #file,line :UInt = #line) -> (data:Data,response:HTTPURLResponse)?{
        let result = resultFor(values, file: file,line:line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success , got \(result) instead.",file:file,line:line)
            return nil
        }
    }
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }
    private func anyData() -> Data{
        return Data.init("any data".utf8)
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
            let error : Error?
        }
        private static var stub : Stub?
        private static var requestObserver : ((URLRequest)->Void)?
        
        static func stub(data: Data?, response:URLResponse?,error:Error?){
            stub = Stub(data: data, response: response, error: error)
        }
        static func observeRequests(observer:@escaping(URLRequest)->Void){
            requestObserver = observer
        }
        static func startInterceptingRequests(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        static func stopInterceptingRequests(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        override func startLoading()  {
            if let requestObserver = URLProtocolStub.requestObserver{
                client?.urlProtocolDidFinishLoading(self)
                return  requestObserver(request)
            }
           
            guard let stub = URLProtocolStub.stub else {return}
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
        URLProtocolStub.startInterceptingRequests()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocolStub.stopInterceptingRequests()
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

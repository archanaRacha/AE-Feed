//
//  URLSessionHTTPClienTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 28/02/24.
//

import XCTest
import AE_Feed
import AEFeedAPI


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
        var task: HTTPClientTask?
        URLProtocolStub.onStartLoading { task?.cancel() }
        _ = resultErrorFor(taskHandler: { task = $0 }) as NSError?
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
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        let sut = URLSessionHTTPClient(session: session)
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
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    private func httpURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        URLProtocolStub.removeStub()
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

//
//  CacheFeedUserCaseTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 23/04/24.
//

import XCTest
import AE_Feed
class LocalFeedLoader{
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    func save(_ items : [FeedItem]){
        store.deleteCacheFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items,timestamp: self.currentDate())
            }
            
        }
    }
}
class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    enum ReceivedMessage : Equatable {
        case deleteCachedFeed
        case insert([FeedItem],Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    func deleteCacheFeed(completion:@escaping DeletionCompletion){

        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    func completeDeletion(with error:Error, at index:Int = 0){
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0){
        deletionCompletions[index](nil)
    }
    func insert(_ items : [FeedItem],timestamp: Date ){
        receivedMessages.append(.insert(items, timestamp))
    }
}
final class CacheFeedUserCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages , [])
    }
    
    func test_save_requestsCacheDeletion(){
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT()
        
        sut.save(items)
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed])
    }
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSucessfulDeletion(){
        let timestamp = Date()
        let items = [uniqueItem(),uniqueItem()]
        let (sut,store) = makeSUT(currentDate: { timestamp })
        sut.save(items)
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed,.insert(items, timestamp)])

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
    

    //MARK: Helpers
    private func makeSUT(currentDate:@escaping() -> Date = Date.init,file:StaticString = #file, line : UInt = #line) -> (sut:LocalFeedLoader, store: FeedStore ){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store,currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }
}

//
//  FeedViewControllerTests.swift
//  Prototype
//
//  Created by archana racha on 12/07/24.
//

import XCTest
import UIKit
import AE_Feed

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut,loader) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount,0,"Expected no loading requests before view is loaded.")
   
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount,1,"Expected a loading request once view is loaded")
   
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request once user initiates another reload")
   }
    
    func test_loadingFeedIndicator_isVisisbleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
//        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
//        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        sut.simulateUserInitiatedFeedReload()
//        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoading(at: 1)
//        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completes with error")
    }
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description:"a description", location: "a location")
        let image1 = makeImage(description:nil, location: "another location")
        let image2 = makeImage(description:"another description", location: nil)
        let image3 = makeImage(description:nil, location: nil)
        let (sut, loader) = makeSUT()
       
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with : [image0], at : 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0,image1,image2,image3], at: 1)
        assertThat(sut, isRendering: [image0,image1,image2,image3])
        
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError(){
        let image0 = makeImage()
        let (sut,loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at:1)
        assertThat(sut, isRendering: [image0])
        
        
    }
    
    func test_feedImageView_loadsImageURL_whenVisible(){
        let image0 = makeImage(url:URL(string: "http://url-0.com")!)
        let image1 = makeImage(url:URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [],"Expected no image URL requests until views become visible")
        
        sut.simulateFeedImageViewVisible(at:0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url],"Expected first image url request once first view becomes visible")
        
        sut.simulateFeedImageViewVisible(at:1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url,image1.url],"Expected second image url request once second view becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore(){
        let image0 = makeImage(url: URL(string:"http://url-0.com")!)
        let image1 = makeImage(url: URL(string:"http://url-1.com")!)
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0,image1],at : 0)
        XCTAssertEqual(loader.cancelledImageURLs,[],"Expected no cancelled image URL requests until image is not visible")
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url,image1.url], "Expected two cancelled image URL requests once second image is not visible anymore")
        
    }

// MARK: Helpers
    
    private func makeSUT(file: StaticString = #file,line: UInt = #line) -> (sut : FeedViewController,loader:LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader )
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }
    
    private func assertThat(_ sut:FeedViewController, isRendering feed:[FeedImage], file :StaticString = #file, line:UInt = #line){
        guard sut.numberOfRenderedFeedImageViews() == feed.count else{
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead",file: file, line: line)
        }
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    private func assertThat(_ sut:FeedViewController,hasViewConfiguredFor image: FeedImage, at index:Int, file :StaticString = #file, line:UInt = #line){
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instace, got \(String(describing: view)) instead", file:file, line: line)
        }
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible)
        
        XCTAssertEqual(cell.locationText, image.location,"Expected location text to be \(String(describing: image.location)) for image view at index (\(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description,"Expected description text to be \(String(describing: image.description)) for image view at index (\(index))", file:file,line:line)
    }
    private func makeImage(description: String? = nil, location: String? = nil,url: URL = URL(string:"http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    class LoaderSpy: FeedLoader,FeedImageDataLoader {
       
        
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var loadFeedCallCount : Int {
            return feedRequests.count
        }
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        func completeFeedLoading(with feed: [FeedImage] = [],at index:Int){
            feedRequests[index](.success(feed))
        }
        func completeFeedLoadingWithError(at index:Int = 0){
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
            
        }
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()
        func loadImageData(from url: URL) {
            loadedImageURLs.append(url)
        }
        func cancelImageDataLoad(from url: URL) {
            cancelledImageURLs.append(url)
        }
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    var locationText : String? {
        return locationLabel.text
    }
    var descriptionText : String? {
        return descriptionLabel.text
    }
}
private extension UIRefreshControl{
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
    
}
private extension FeedViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    @discardableResult
    func simulateFeedImageViewVisible(at index : Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    func simulateFeedImageViewNotVisible(at row : Int) {
        let view = simulateFeedImageViewVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)
    }
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    func feedImageView(at row:Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
        
    }
    private var feedImagesSection: Int{
        return 0
    }
}


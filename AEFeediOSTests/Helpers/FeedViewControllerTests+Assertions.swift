//
//  FeedViewControllerTests+Assertions.swift
//  AEFeediOSTests
//
//  Created by archana racha on 26/08/24.
//

import XCTest
import AE_Feed
import AEFeediOS

extension FeedUIIntegrationTests{
    func assertThat(_ sut:FeedViewController, isRendering feed:[FeedImage], file :StaticString = #file, line:UInt = #line){
        
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedFeedImageViews() == feed.count else{
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead",file: file, line: line)
        }
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    func assertThat(_ sut:FeedViewController,hasViewConfiguredFor image: FeedImage, at index:Int, file :StaticString = #file, line:UInt = #line){
        let view = sut.feedImageView(at: index)
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instace, got \(String(describing: view)) instead", file:file, line: line)
        }
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible)
        
        XCTAssertEqual(cell.locationText, image.location,"Expected location text to be \(String(describing: image.location)) for image view at index (\(index)", file: file, line: line)
        XCTAssertEqual(cell.descriptionText, image.description,"Expected description text to be \(String(describing: image.description)) for image view at index (\(index))", file:file,line:line)
    }
   
}

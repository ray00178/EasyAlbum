import XCTest
@testable import EasyAlbum

final class EasyAlbumTests: XCTestCase {
    
    static var allTests = [
        ("test_image_use_bundle", test_image_use_bundle),
    ]
    
    func test_image_use_bundle() {
        XCTAssertNotNil(UIImage.bundle(image: .close))
        XCTAssertNotNil(UIImage.bundle(image: .camera))
        XCTAssertNotNil(UIImage.bundle(image: .done))
    }
}

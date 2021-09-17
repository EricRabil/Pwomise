    import XCTest
    @testable import Pwomise

    final class PwomiseTests: XCTestCase {
        func testRace() {
            var fulfilled = false
            
            Promise<Void>.any([
                Promise { resolve, reject in
                    resolve(())
                },
                Promise { resolve, reject in
                    resolve(())
                }
            ]).then { _ in
                XCTAssert(!fulfilled, "resolved multiple times")
                
                fulfilled = true
            }
        }
    }

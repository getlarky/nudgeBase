import XCTest
@testable import KeyValueStore

final class KeyValueStoreTests: XCTestCase {
    
    let testKey = "testKey"
    
    func test_put_getString_positive() throws {
        let testValue = "testValue"
        KeyValueStore.putString(key: testKey, value: testValue)
        XCTAssertEqual(testValue, KeyValueStore.getString(key: testKey))
    }
    
    func test_put_getString_negative() throws {
        let testValue1 = "testValue1"
        let testValue2 = "testValue2"
        KeyValueStore.putString(key: testKey, value: testValue1)
        XCTAssertNotEqual(testValue2, KeyValueStore.getString(key: testKey))
    }
    
    func test_put_getBoolean_positive() throws {
        let testValue = true
        KeyValueStore.putBoolean(key: testKey, value: testValue)
        XCTAssertEqual(testValue, KeyValueStore.getBoolean(key: testKey))
    }
    
    func test_put_getBoolean_negative() throws {
        let testValue1 = true
        let testValue2 = false
        KeyValueStore.putBoolean(key: testKey, value: testValue1)
        XCTAssertNotEqual(testValue2, KeyValueStore.getBoolean(key: testKey))
    }
    
    func test_put_getDouble_positive() throws {
        let testValue = 1.234
        KeyValueStore.putDouble(key: testKey, value: testValue)
        XCTAssertEqual(testValue, KeyValueStore.getDouble(key: testKey))
    }
    
    func test_put_getDouble_negative() throws {
        let testValue1 = 1.234
        let testValue2 = 2.345
        KeyValueStore.putDouble(key: testKey, value: testValue1)
        XCTAssertNotEqual(testValue2, KeyValueStore.getDouble(key: testKey))
    }
    
    func test_put_getFloat_positive() throws {
        let testValue = Float(3.14)
        KeyValueStore.putFloat(key: testKey, value: testValue)
        XCTAssertEqual(testValue, KeyValueStore.getFloat(key: testKey))
    }
    
    func test_put_getFloat_negative() throws {
        let testValue1 = Float(3.14)
        let testValue2 = Float(1.234)
        KeyValueStore.putFloat(key: testKey, value: testValue1)
        XCTAssertNotEqual(testValue2, KeyValueStore.getFloat(key: testKey))
    }
    
    func test_put_getInt_positive() throws {
        let testValue = 10
        KeyValueStore.putInt(key: testKey, value: testValue)
        XCTAssertEqual(testValue, KeyValueStore.getInt(key: testKey))
    }
    
    func test_put_getInt_negativetive() throws {
        let testValue1 = 10
        let testValue2 = 0
        KeyValueStore.putInt(key: testKey, value: testValue1)
        XCTAssertNotEqual(testValue2, KeyValueStore.getInt(key: testKey))
    }
}

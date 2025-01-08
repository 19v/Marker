import CoreLocation

extension CommonUtils {
    
    // 将经纬度信息转换为地理信息
    static func getAddressFromCoordinates(latitude: Double, longitude: Double) async throws -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first {
            let address = [
                placemark.name,
                placemark.locality,
                placemark.administrativeArea,
                placemark.country
            ].compactMap { $0 }.joined(separator: ", ")
            return address
        } else {
            throw NSError(domain: "AddressError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Address not found"])
        }
    }
    
}

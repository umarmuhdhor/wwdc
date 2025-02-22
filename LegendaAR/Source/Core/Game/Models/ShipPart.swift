import Foundation
import simd

struct ShipPart: Identifiable {
    let id: Int
    let name: String
    let modelName: String
    let position: SIMD3<Float>
    let rotation: simd_quatf
    let previewImageName: String
    var isPlaced: Bool = false
    
    static func defaultParts() -> [ShipPart] {
        [
            ShipPart(id: 1,
                     name: "Front Upper",
                     modelName: "FrUp",
                     position: SIMD3<Float>(-0.6, 0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "FrUp"),
            
            ShipPart(id: 2,
                     name: "Front Lower",
                     modelName: "FrLow",
                     position: SIMD3<Float>(-0.6, -0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "FrLow"),
            
            ShipPart(id: 3,
                     name: "Middle Upper",
                     modelName: "MdUp",
                     position: SIMD3<Float>(0, 0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "MdUp"),
            
            ShipPart(id: 4,
                     name: "Middle Lower",
                     modelName: "MdLow",
                     position: SIMD3<Float>(0, -0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "MdLow"),
            
            ShipPart(id: 5,
                     name: "Back Upper",
                     modelName: "BkUp",
                     position: SIMD3<Float>(0.6, 0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "BkUp"),
            
            ShipPart(id: 6,
                     name: "Back Lower",
                     modelName: "BkLow",
                     position: SIMD3<Float>(0.6, -0.09, 0),
                     rotation: simd_quatf(angle: 0, axis: [0, 1, 0]),
                     previewImageName: "BkLow")
        ]
    }
}

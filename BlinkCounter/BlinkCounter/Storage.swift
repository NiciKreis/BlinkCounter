import Foundation
import SwiftData
import ARKit

final class FaceStorage {
    var blendShapes: [(ARFaceAnchor.BlendShapeLocation, NSNumber)] = []
    var timeStamp: String
    
    init(blendShapes: [(ARFaceAnchor.BlendShapeLocation, NSNumber)]) {
        let calendar = Calendar.current
        let timeZone = calendar.timeZone
        let components = calendar.dateComponents(in: timeZone, from: Date())

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeString = timeFormatter.string(from: components.date!)

        self.timeStamp = timeString

        self.blendShapes = blendShapes
    }

    func outputKey() -> [String]{
        var outputArray: [String] = []
        let sortedBlendShapes = blendShapes.sorted { $0.0.rawValue.description < $1.0.rawValue.description }    //Sorts the Blendshapes by Name
        
        outputArray.append("\(timeStamp)")

        
        for (key, _) in sortedBlendShapes {
            outputArray.append("\(key.rawValue)")
        }
        
        return outputArray
    }
    
    func outputValue() -> [String] {
        var outputArray: [String] = []
        let sortedBlendShapes = blendShapes.sorted { $0.0.rawValue.description < $1.0.rawValue.description }    //Sorts the Blendshapes by Name

        outputArray.append("\(timeStamp)")

        for (_, value) in sortedBlendShapes {
            outputArray.append("\(value)")
        }
        
        return outputArray
    }
}

import Foundation
import UIKit

public class Stopwatch: NSObject {
    var counter: Double
    var timer: Timer?
    var lapTimes: [Double] = []
    
    
    override init() {
        counter = 0.0
        timer = nil
    }
    
    func start(label: UILabel) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.counter += 0.035
            let minutes: String = String(format: "%02d", Int(self.counter / 60))
            let seconds: String = String(format: "%02d", Int(self.counter.truncatingRemainder(dividingBy: 60)))
            let milliseconds: String = String(format: "%02d", Int((self.counter * 100).truncatingRemainder(dividingBy: 100)))
            let timeString = "\(minutes):\(seconds).\(milliseconds)"
            
            DispatchQueue.main.async {
                label.text = timeString
            }
        }
    }
    
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        counter = 0
    }
    
    @objc private func updateCounter() {
        counter += 0.035
    }
}

public class MindGymStopWatchKit {
    
    public init () {}
    
    public let mainStopwatch: Stopwatch = Stopwatch()
    
    public func startTimer(label: UILabel) {
        mainStopwatch.start(label: label)
    }
    
    public func stopTimer() {
        mainStopwatch.stop()
    }
    
    public func resetTimer(label: UILabel) {
        mainStopwatch.reset()
        let minutes: String = String(format: "%02d", Int(mainStopwatch.counter / 60))
        let seconds: String = String(format: "%02d", Int(mainStopwatch.counter.truncatingRemainder(dividingBy: 60)))
        let milliseconds: String = String(format: "%02d", Int((mainStopwatch.counter * 100).truncatingRemainder(dividingBy: 100)))
        let timeString = "\(minutes):\(seconds).\(milliseconds)"
        
        DispatchQueue.main.async { [weak label] in
            label?.text = timeString
        }
        resetRecord()
    }
    
    public func resetRecord() {
        mainStopwatch.lapTimes.removeAll()
    }
    
    public func recordTime() {
        mainStopwatch.lapTimes.append(mainStopwatch.counter)
        printLapTimes()
    }
    
    public func printLapTimes() {
        print("Lap Times:")
        for (index, lapTime) in mainStopwatch.lapTimes.enumerated() {
            let minutes: String = String(format: "%02d", Int(lapTime / 60))
            let seconds: String = String(format: "%02d", Int(lapTime.truncatingRemainder(dividingBy: 60)))
            let milliseconds: String = String(format: "%02d", Int((lapTime * 100).truncatingRemainder(dividingBy: 100)))
            let lapTimeString = "\(minutes):\(seconds).\(milliseconds)"
            print("\(index + 1). \(lapTimeString)")
        }
    }
}



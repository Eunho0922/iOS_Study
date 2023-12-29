import Foundation
import RxSwift

public class MindGaGymKitTimer: NSObject {
    private var initCounter: Double = 0.0
    private var counter: Double = 0.0
    private var timer: Timer?
    private let timerSubject = PublishSubject<String>()
    
    public var timeUpdate: Observable<String> {
        return timerSubject.asObservable()
    }
    
    func setting(count: Double) {
        initCounter = count
        self.counter = count
        let timeString = self.timeString(from: self.counter)
        self.timerSubject.onNext(timeString)
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.counter -= 0.035
            let timeString = self.timeString(from: self.counter)
            self.timerSubject.onNext(timeString)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func restart() {
        counter = initCounter
        let timeString = self.timeString(from: self.counter)
        self.timerSubject.onNext(timeString)
    }

    func reset() {
        counter = 0.0
        initCounter = 0.0
        let timeString = self.timeString(from: self.counter)
        self.timerSubject.onNext(timeString)
    }
    
    private func timeString(from counter: Double) -> String {

        if counter == 0 {
            stop()
        }
        
        let hours: String = String(format: "%02d", Int(counter / 3600))
        let minutes: String = String(format: "%02d", Int(counter / 60))
        let seconds: String = String(format: "%02d", Int(counter.truncatingRemainder(dividingBy: 60)))
        if counter / 3600 >= 1  {
            return "\(hours) : \(minutes) : \(seconds)"
        } else if counter / 60 > 1 {
            return "\(minutes) : \(seconds)"
        } else {
            return "\(minutes) : \(seconds)"
        }
    }
}

public class MindGymTimerKit {
        
    public let mainTimer: MindGaGymKitTimer = MindGaGymKitTimer()
    
    public func setting(count: Double) {
        mainTimer.setting(count: count)
    }
    
    public func startTimer() {
        mainTimer.start()
    }
    
    public func stopTimer() {
        mainTimer.stop()
    }
    
    public func resetTimer() {
        mainTimer.reset()
    }
    
    public func restartTimer() {
        mainTimer.restart()
    }

}


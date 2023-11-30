import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

public class Stopwatch: NSObject {
    var counter: Double
    var timer: Timer?
    
    override init() {
        counter = 0.0
        timer = nil
    }
    
    func start() {
        timer = Timer.scheduledTimer(timeInterval: 0.035, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
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
    
    public init()  {}
    
    fileprivate let mainStopwatch: Stopwatch = Stopwatch()
    
    public func updateTimer(_ stopwatch: Stopwatch, label: UILabel) {
        let minutes: String = String(format: "%02d", Int(stopwatch.counter / 60))
        let seconds: String = String(format: "%02d", Int(stopwatch.counter.truncatingRemainder(dividingBy: 60)))
        let milliseconds: String = String(format: "%02d", Int((stopwatch.counter * 100).truncatingRemainder(dividingBy: 100)))
        let timeString = "\(minutes):\(seconds).\(milliseconds)"
        
        DispatchQueue.main.async { [weak label] in
            label?.text = timeString
        }
    }
}

class ViewController: UIViewController {
    let stopWatchObject = MindGymStopWatchKit()
    var timer: Timer?
    
    let disposeBag = DisposeBag()
    
    var stopWatchButton = UIButton().then {
        $0.backgroundColor = .green
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    var stopWatchResetButton = UIButton().then {
        $0.backgroundColor = .magenta
        $0.setTitle("리셋", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    var recordStopWatchButton = UIButton().then {
        $0.backgroundColor = .gray
        $0.setTitle("랩", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    
    public var stopWatchLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.font = UIFont.monospacedDigitSystemFont(ofSize: 70, weight: .semibold)
        $0.textColor = .white
        $0.text = "00:00.00"
    }
    
    var lapTimes: [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        layout()
        buttonTap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopTimer()
    }
    
    private func layout() {
        [stopWatchLabel, stopWatchButton, stopWatchResetButton, recordStopWatchButton].forEach { view.addSubview($0) }
        
        stopWatchLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(100.0)
            $0.width.equalToSuperview()
        }
        
        stopWatchButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50.0)
            $0.centerY.equalToSuperview().offset(50.0)
        }
        
        stopWatchResetButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50.0)
            $0.centerY.equalToSuperview().offset(100.0)
        }
        
        recordStopWatchButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50.0)
            $0.centerY.equalToSuperview().offset(150.0)
        }
    }
    
    private func buttonTap() {
        var isRunning: Bool = false
        
        stopWatchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if isRunning {
                    self?.stopTimer()
                    self?.stopWatchResetButton.isHidden = false
                    self?.stopWatchButton.backgroundColor = .green
                    self?.stopWatchButton.setTitle("시작", for: .normal)
                    self?.recordStopWatchButton.isHidden = true

                } else {
                    self?.startTimer()
                    self?.stopWatchResetButton.isHidden = true
                    self?.stopWatchButton.backgroundColor = .red
                    self?.stopWatchButton.setTitle("끝", for: .normal)
                    self?.recordStopWatchButton.isHidden = false

                }
                isRunning.toggle()
            })
            .disposed(by: disposeBag)
        
        stopWatchResetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.resetTimer()
                isRunning = false
            })
            .disposed(by: disposeBag)
        
        recordStopWatchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.recordTime()
            })
            .disposed(by: disposeBag)
    }
    
    private func startTimer() {
        stopWatchObject.mainStopwatch.start()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.035, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.stopWatchObject.updateTimer(self.stopWatchObject.mainStopwatch, label: self.stopWatchLabel)
        }
    }
    
    private func stopTimer() {
        stopWatchObject.mainStopwatch.stop()
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopWatchObject.mainStopwatch.reset()
        stopWatchObject.updateTimer(stopWatchObject.mainStopwatch, label: stopWatchLabel)
    }
    
    private func recordTime() {
        lapTimes.append(stopWatchObject.mainStopwatch.counter)
        printLapTimes()
    }
    
    private func printLapTimes() {
        print("Lap Times:")
        for (index, lapTime) in lapTimes.enumerated() {
            let minutes: String = String(format: "%02d", Int(lapTime / 60))
            let seconds: String = String(format: "%02d", Int(lapTime.truncatingRemainder(dividingBy: 60)))
            let milliseconds: String = String(format: "%02d", Int((lapTime * 100).truncatingRemainder(dividingBy: 100)))
            let lapTimeString = "\(minutes):\(seconds).\(milliseconds)"
            print("\(index + 1). \(lapTimeString)")
        }
    }
}

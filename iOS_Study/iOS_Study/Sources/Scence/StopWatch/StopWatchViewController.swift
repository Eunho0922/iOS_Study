import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
//    var timer: Timer?
    
    var lapRecords: [String] = []
    
    let disposeBag = DisposeBag()
    
    var stopWatchOnOffButton = UIButton().then {
        $0.backgroundColor = .green
        $0.setTitle("시작", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.layer.cornerRadius = 45.0
    }
    
    var stopWatchResetLabButton = UIButton().then {
        $0.backgroundColor = .darkGray
        $0.isEnabled = false
        $0.setTitle("랩", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 45.0
    }
    
    public var stopWatchLabel = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.font = UIFont.monospacedDigitSystemFont(ofSize: 100, weight: .ultraLight)
        $0.textColor = .white
        $0.text = "00:00.00"
    }
    
    private let stopWatchObject = MindGymStopWatchKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        stopWatchObject.mainStopwatch.timeUpdateHandler = { [weak self] timeString in
            self?.stopWatchLabel.text = timeString
        }
        
        stopWatchObject.mainStopwatch.recordUpdateHandler = { lapTimesString in
            self.lapRecords.append(lapTimesString.last ?? "")
            print("Lap Records: \(self.lapRecords )")
        }
        
        layout()
        buttonTap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopWatchObject.stopTimer()
    }
    
    private func layout() {
        [stopWatchLabel, stopWatchOnOffButton, stopWatchResetLabButton].forEach { view.addSubview($0) }
        
        stopWatchLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(140.0)
            $0.width.equalToSuperview()
        }
        
        stopWatchOnOffButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20.0)
            $0.width.height.equalTo(90.0)
            $0.centerY.equalToSuperview().offset(-50.0)
        }
        
        stopWatchResetLabButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20.0)
            $0.width.height.equalTo(90.0)
            $0.centerY.equalToSuperview().offset(-50.0)
        }
    }
    
    private func buttonTap() {
        var isRunning: Bool = false
        
        stopWatchOnOffButton.rx.tap
            .subscribe(onNext: { [self] in
                if isRunning {
                    stopWatchObject.stopTimer()
                    stopWatchOnOffButton.backgroundColor = .green
                    stopWatchOnOffButton.setTitle("시작", for: .normal)
                    lapRecords.removeAll()
                    stopWatchResetLabButton.setTitle("재설정", for: .normal)
                    stopWatchResetLabButton.isEnabled = true
                } else {
                    stopWatchObject.startTimer()
                    stopWatchOnOffButton.backgroundColor = .red
                    stopWatchResetLabButton.setTitle("랩", for: .normal)
                    stopWatchResetLabButton.backgroundColor = .lightGray
                    stopWatchResetLabButton.isEnabled = true
                    stopWatchOnOffButton.setTitle("끝", for: .normal)
                }
                isRunning.toggle()
            })
            .disposed(by: disposeBag)
        
        stopWatchResetLabButton.rx.tap
            .subscribe(onNext: { [self] in
                if isRunning {
                    stopWatchObject.recordTime()
                } else {
                    stopWatchObject.resetTimer()
                    stopWatchLabel.text = "00:00.00"
                    isRunning = false
                    stopWatchResetLabButton.setTitle("랩", for: .normal)
                    stopWatchResetLabButton.backgroundColor = .darkGray
                    stopWatchResetLabButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
}

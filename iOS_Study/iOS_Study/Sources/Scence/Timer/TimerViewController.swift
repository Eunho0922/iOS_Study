import UIKit
import SnapKit
import Then
import RxSwift

class TimerViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    private let cirularProgressBar = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 350, height: 350), lineWidth: 6, rounded: true, timeToFill: 60)
    
    private let stopButton = UIButton().then {
        $0.backgroundColor = .red
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        cirularProgressBar.progressColor = .systemBlue
        cirularProgressBar.trackColor = .lightGray
        cirularProgressBar.center = view.center

        cirularProgressBar.progress = 1.0
        view.backgroundColor = .white

        layout()
        tapped()
    }
    
    private func layout() {
        view.addSubview(cirularProgressBar)
        view.addSubview(stopButton)
        
        cirularProgressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(88.0)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(350.0)
        }
        
        stopButton.snp.makeConstraints {
            $0.centerX.bottom.equalToSuperview().offset(-20.0)
            $0.width.height.equalTo(100.0)
        }
    }
    
    var count: Bool = true
    private func tapped() {
        stopButton.rx.tap
            .subscribe(onNext: { [self] in
                if count == true {
                    self.cirularProgressBar.stopProgress()
                    self.count = false
                } else {
                    self.cirularProgressBar.setProgress(to: cirularProgressBar.progress)
                    self.count = true
                }
            }).disposed(by: disposeBag)
    }
}

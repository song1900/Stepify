//
//  ViewController.swift
//  Stepify
//
//  Created by 송우진 on 12/11/24.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let pedometer: CMPedometer = .init()
    let stepCountLabel: UILabel = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(stepCountLabel)
        stepCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stepCountLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        updateCountLabel(0)
        getPedometerData()
        startPedometerUpdates()
    }
    

    func updateCountLabel(_ count: NSNumber) {
        Task { @MainActor in
            self.stepCountLabel.text = "걸음 수: \(count)"
        }
    }
}

extension ViewController {
    // 만보기 시작
    func startPedometerUpdates() {
        // 만보기 데이터 이용 가능 여부 확인
        guard CMPedometer.isStepCountingAvailable() else {
            stepCountLabel.text = "만보기 기능을 사용할 수 없습니다."
            return
        }
        
        // 실시간 걸음 수 업데이트
        pedometer.startUpdates(from: Date()) { [weak self] data, error in
            if let error {
                print("걸음 수 업데이트 에러: \(error.localizedDescription)")
            }
            guard let data else { return }
            
            if let distance = data.distance {
                print("이동 거리: \(distance) 미터")
            }
            
            if let floorsup = data.floorsAscended {
                print("올라간 층 수: \(floorsup)")
            }
            
            if let floorsDown = data.floorsDescended {
                print("내려간 층 수: \(floorsDown)")
            }
            
            if let avgPace = data.averageActivePace {
                print("평균 활동 페이스: \(avgPace) 초/미터")
            }
            
            if let pace = data.currentPace {
                print("현재 페이스: \(pace) 초/미터")
                let speed = 1 / pace.doubleValue
                print("현재 속도: \(speed) 미터/초")
            }
            
            if let cadence = data.currentCadence {
                print("현재 걸음 빈도: \(cadence) 걸음/초")
                let stepsPerMinute = cadence.doubleValue * 60
                print("분당 걸음 수: \(stepsPerMinute)")
            }
            
            
            self?.updateCountLabel(data.numberOfSteps)
        }
    }
    
    // 걸음 수 통계
    func getPedometerData() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date()) // 오늘 0시
        let endDate = Date() // 현재 시간

        pedometer.queryPedometerData(from: startDate, to: endDate) { data, error in
            guard let data = data, error == nil else { return }
            if let error {
                print("걸음 수 통계 에러: \(error.localizedDescription)")
            }
            
            print("오늘 걸음 수: \(data.numberOfSteps)")
        }
    }
}

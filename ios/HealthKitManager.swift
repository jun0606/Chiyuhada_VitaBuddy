//
//  HealthKitManager.swift
//  Runner
//
//  Created by Chiyuhada Vita Buddy
//  iOS HealthKit 연동을 위한 네이티브 관리 클래스
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    // 지원하는 건강 데이터 타입들
    private var readTypes: Set<HKObjectType> {
        return [
            // 걸음 수
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,

            // 칼로리 소모 (활동 에너지)
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,

            // 심박수
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,

            // 운동 세션
            HKWorkoutType.workoutType(),
            HKSeriesType.workoutRoute(),

            // 수면 데이터 (선택)
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,

            // 체중 (선택)
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
        ]
    }

    private var writeTypes: Set<HKSampleType> {
        return [
            // 앱에서 기록한 운동 데이터 저장용
            HKWorkoutType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]
    }

    // MARK: - 권한 관리

    /// HealthKit 사용 가능 여부 확인
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    /// HealthKit 권한 요청
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthDataAvailable() else {
            let error = NSError(domain: "HealthKit",
                              code: 1,
                              userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"])
            completion(false, error)
            return
        }

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    /// 권한 상태 확인
    func getAuthorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return healthStore.authorizationStatus(for: type)
    }

    /// 모든 필수 권한이 승인되었는지 확인
    func hasRequiredPermissions() -> Bool {
        let essentialTypes = [
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        return essentialTypes.allSatisfy { type in
            getAuthorizationStatus(for: type) == .sharingAuthorized
        }
    }

    // MARK: - 데이터 조회

    /// 오늘 걸음 수 조회
    func getTodaySteps(completion: @escaping (Double?, Error?) -> Void) {
        getSteps(for: Date(), completion: completion)
    }

    /// 특정 날짜 걸음 수 조회
    func getSteps(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        getSteps(from: startDate, to: endDate, completion: completion)
    }

    /// 기간별 걸음 수 조회
    func getSteps(from startDate: Date, to endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(nil, NSError(domain: "HealthKit", code: 2, userInfo: [NSLocalizedDescriptionKey: "Step count type not available"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count())
                completion(steps, nil)
            }
        }

        healthStore.execute(query)
    }

    /// 오늘 칼로리 소모량 조회
    func getTodayCaloriesBurned(completion: @escaping (Double?, Error?) -> Void) {
        getCaloriesBurned(for: Date(), completion: completion)
    }

    /// 특정 날짜 칼로리 소모량 조회
    func getCaloriesBurned(for date: Date, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        getCaloriesBurned(from: startDate, to: endDate, completion: completion)
    }

    /// 기간별 칼로리 소모량 조회
    func getCaloriesBurned(from startDate: Date, to endDate: Date, completion: @escaping (Double?, Error?) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil, NSError(domain: "HealthKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Active energy burned type not available"]))
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: calorieType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
                completion(calories, nil)
            }
        }

        healthStore.execute(query)
    }

    /// 운동 세션 조회
    func getWorkouts(from startDate: Date, to endDate: Date, completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: HKWorkoutType.workoutType(),
                                predicate: predicate,
                                limit: HKObjectQueryNoLimit,
                                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                    return
                }

                guard let workoutSamples = samples as? [HKWorkout] else {
                    completion([], nil)
                    return
                }

                let workouts = workoutSamples.map { workout -> [String: Any] in
                    return [
                        "id": workout.uuid.uuidString,
                        "type": workout.workoutActivityType.rawValue,
                        "title": workout.metadata?[HKMetadataKeyWorkoutBrandName] as? String ?? "Workout",
                        "start_time": workout.startDate.timeIntervalSince1970 * 1000,
                        "end_time": workout.endDate.timeIntervalSince1970 * 1000,
                        "duration_minutes": workout.duration / 60.0,
                        "calories": workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0,
                        "distance": workout.totalDistance?.doubleValue(for: HKUnit.meter()) ?? 0.0,
                        "source": "HealthKit"
                    ]
                }

                completion(workouts, nil)
            }
        }

        healthStore.execute(query)
    }

    /// 심박수 데이터 조회 (최근 값)
    func getLatestHeartRate(completion: @escaping (Double?, Date?, Error?) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion(nil, nil, NSError(domain: "HealthKit", code: 4, userInfo: [NSLocalizedDescriptionKey: "Heart rate type not available"]))
            return
        }

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType,
                                predicate: nil,
                                limit: 1,
                                sortDescriptors: [sortDescriptor]) { _, samples, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, nil, error)
                    return
                }

                if let sample = samples?.first as? HKQuantitySample {
                    let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                    completion(heartRate, sample.startDate, nil)
                } else {
                    completion(nil, nil, nil)
                }
            }
        }

        healthStore.execute(query)
    }

    // MARK: - 데이터 저장

    /// 운동 데이터 저장
    func saveWorkout(type: HKWorkoutActivityType,
                    startDate: Date,
                    endDate: Date,
                    calories: Double,
                    distance: Double? = nil,
                    completion: @escaping (Bool, Error?) -> Void) {

        let workout = HKWorkout(activityType: type,
                               start: startDate,
                               end: endDate,
                               duration: endDate.timeIntervalSince(startDate),
                               totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories),
                               totalDistance: distance != nil ? HKQuantity(unit: HKUnit.meter(), doubleValue: distance!) : nil,
                               metadata: [HKMetadataKeyWorkoutBrandName: "Chiyuhada Vita Buddy"])

        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}

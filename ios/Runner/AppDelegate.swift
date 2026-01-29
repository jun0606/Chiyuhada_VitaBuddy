import Flutter
import UIKit
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // HealthKit MethodChannel 설정
    setupHealthKitChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupHealthKitChannel() {
    let controller = window?.rootViewController as! FlutterViewController
    let healthChannel = FlutterMethodChannel(name: "com.example.health_connect",
                                           binaryMessenger: controller.binaryMessenger)

    healthChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      self?.handleHealthMethodCall(call, result: result)
    }
  }

  private func handleHealthMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let healthKitManager = HealthKitManager.shared

    switch call.method {
    // HealthKit 권한 관련
    case "requestIOSHealthKitPermissions":
      healthKitManager.requestAuthorization { success, error in
        if let error = error {
          result(FlutterError(code: "AUTH_ERROR",
                            message: error.localizedDescription,
                            details: nil))
        } else {
          result(success)
        }
      }

    case "getIOSHealthKitPermissionsStatus":
      let hasPermissions = healthKitManager.hasRequiredPermissions()
      result(hasPermissions)

    // 데이터 조회
    case "getTodaySteps":
      healthKitManager.getTodaySteps { steps, error in
        if let error = error {
          result(FlutterError(code: "DATA_ERROR",
                            message: error.localizedDescription,
                            details: nil))
        } else {
          result(steps ?? 0.0)
        }
      }

    case "getTodayCaloriesBurned":
      healthKitManager.getTodayCaloriesBurned { calories, error in
        if let error = error {
          result(FlutterError(code: "DATA_ERROR",
                            message: error.localizedDescription,
                            details: nil))
        } else {
          result(calories ?? 0.0)
        }
      }

    case "getIOSWorkouts":
      guard let args = call.arguments as? [String: Any],
            let startTimeMillis = args["startTime"] as? Int,
            let endTimeMillis = args["endTime"] as? Int else {
        result(FlutterError(code: "INVALID_ARGS",
                          message: "Missing startTime or endTime arguments",
                          details: nil))
        return
      }

      let startDate = Date(timeIntervalSince1970: TimeInterval(startTimeMillis) / 1000.0)
      let endDate = Date(timeIntervalSince1970: TimeInterval(endTimeMillis) / 1000.0)

      healthKitManager.getWorkouts(from: startDate, to: endDate) { workouts, error in
        if let error = error {
          result(FlutterError(code: "DATA_ERROR",
                            message: error.localizedDescription,
                            details: nil))
        } else {
          result(workouts ?? [])
        }
      }

    case "getLatestHeartRate":
      healthKitManager.getLatestHeartRate { heartRate, date, error in
        if let error = error {
          result(FlutterError(code: "DATA_ERROR",
                            message: error.localizedDescription,
                            details: nil))
        } else if let heartRate = heartRate, let date = date {
          result([
            "heartRate": heartRate,
            "timestamp": date.timeIntervalSince1970 * 1000
          ])
        } else {
          result(nil)
        }
      }

    // Health Connect 호환성 (Android 전용)
    case "isHealthConnectInstalled",
         "openHealthConnectStore",
         "requestHealthConnectPermissions",
         "getHealthConnectPermissionsStatus":
      // iOS에서는 Health Connect 관련 메서드를 지원하지 않음
      result(FlutterMethodNotImplemented)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

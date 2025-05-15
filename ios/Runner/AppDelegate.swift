import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    configurePushNotifications(application)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ Recibir token de APNs
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)

    // También puedes enviar el token manualmente a Firebase (opcional)
    Messaging.messaging().apnsToken = deviceToken

    // Opcional: imprimirlo
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let tokenString = tokenParts.joined()
      print("📱 Device Token iOS: \(tokenString)")
  }

  private func configurePushNotifications(_ application: UIApplication) {
    UNUserNotificationCenter.current().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print("❌ Error al pedir permisos: \(error.localizedDescription)")
      }
      print("🔔 Permisos concedidos: \(granted)")
    }

    application.registerForRemoteNotifications()
  }
}

// MARK: - Manejo de notificaciones
extension AppDelegate: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("📩 Notificación tocada: \(userInfo)")
    completionHandler()
  }
}

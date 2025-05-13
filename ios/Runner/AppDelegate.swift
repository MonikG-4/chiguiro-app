import UIKit
import Flutter
import FirebaseCore
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    //  Inicializar Firebase
    FirebaseApp.configure()

    //  Configurar notificaciones push en iOS
    configurePushNotifications(application)

    //  Registrar plugins de Flutter
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Configuración de notificaciones push en iOS
  private func configurePushNotifications(_ application: UIApplication) {
    UNUserNotificationCenter.current().delegate = self

    // Solicitar permisos de notificación
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error = error {
        print(" Error al solicitar permisos de notificación: \(error.localizedDescription)")
      }
      print("Permisos de notificación otorgados: \(granted)")
    }

    application.registerForRemoteNotifications()
  }
}

// MARK: -  Manejo de Notificaciones en iOS
extension AppDelegate: UNUserNotificationCenterDelegate {

  /// Muestra notificaciones en primer plano (cuando la app está abierta)
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  /// Manejo de notificaciones cuando el usuario toca la notificación
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print(" Notificación tocada: \(userInfo)")
    completionHandler()
  }
}

import UIKit
import Flutter
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate  {
    
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
    
    /// Muestra notificaciones en primer plano (cuando la app está abierta)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .badge, .sound])
    }
    
    /// Manejo de notificaciones cuando el usuario toca la notificación
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print(" Notificación tocada: \(userInfo)")
        completionHandler()
    }
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
        
        override func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler([.alert, .badge, .sound])
        }
        
        override func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            let userInfo = response.notification.request.content.userInfo
            print("📩 Notificación tocada: \(userInfo)")
            completionHandler()
        }    }
}
    
/*
 MARK THIS AS USELESS  ------
 Bad code
    // MARK: - Manejo de notificaciones
    extension AppDelegate: UNUserNotificationCenterDelegate {
        override func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler([.alert, .badge, .sound])
        }
        
        override func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            let userInfo = response.notification.request.content.userInfo
            print("📩 Notificación tocada: \(userInfo)")
            completionHandler()
        }
    }
*/

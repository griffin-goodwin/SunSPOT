import SwiftUI
import BackgroundTasks

@main
struct SpaceWeatherApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - App Delegate for Background Tasks

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Setup notification categories
        NotificationManager.shared.setupNotificationCategories()
        
        // Register background tasks
        NotificationManager.shared.registerBackgroundTasks()
        
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule background refresh when app goes to background
        if NotificationManager.shared.hasAnyNotificationsEnabled {
            NotificationManager.shared.scheduleBackgroundRefresh()
        }
    }
}

// MARK: - Notification Delegate (separate to avoid actor isolation issues)

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationDelegate()
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let eventId = userInfo["eventId"] as? String {
            // Could navigate to specific event here
            print("User tapped notification for event: \(eventId)")
        }
        
        completionHandler()
    }
}

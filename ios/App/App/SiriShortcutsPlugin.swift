import Capacitor
import Intents
import UIKit

@objc(SiriShortcutsPlugin)
public class SiriShortcutsPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "SiriShortcutsPlugin"
    public let jsName = "SiriShortcuts"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "donate", returnType: CAPPluginReturnPromise),
    ]

    @objc func donate(_ call: CAPPluginCall) {
        let activityType = call.getString("activityType") ?? "com.vigilplatform.app.briefing"
        let title = call.getString("title") ?? "View Morning Brief"

        let activity = NSUserActivity(activityType: activityType)
        activity.title = title
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.suggestedInvocationPhrase = "Show my Vigil briefing"
        activity.persistentIdentifier = activityType

        DispatchQueue.main.async {
            self.bridge?.viewController?.userActivity = activity
            activity.becomeCurrent()
        }

        call.resolve(["donated": true])
    }
}

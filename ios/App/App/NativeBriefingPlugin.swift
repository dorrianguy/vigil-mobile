import Capacitor
import UIKit

@objc(NativeBriefingPlugin)
public class NativeBriefingPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "NativeBriefingPlugin"
    public let jsName = "NativeBriefing"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "openBriefing", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getInsights", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "saveInsight", returnType: CAPPluginReturnPromise),
    ]

    @objc func openBriefing(_ call: CAPPluginCall) {
        let title = call.getString("title") ?? "Morning Brief"

        DispatchQueue.main.async {
            let vc = NativeBriefingViewController()
            vc.briefingTitle = title
            vc.modalPresentationStyle = .fullScreen
            self.bridge?.viewController?.present(vc, animated: true)
        }

        call.resolve(["opened": true])
    }

    @objc func getInsights(_ call: CAPPluginCall) {
        let insights = InsightStorage.shared.getInsights()
        let mapped = insights.map { ["id": $0.id, "title": $0.title, "content": $0.content, "timestamp": $0.timestamp, "severity": $0.severity] as [String: Any] }
        call.resolve(["insights": mapped])
    }

    @objc func saveInsight(_ call: CAPPluginCall) {
        guard let title = call.getString("title"), let content = call.getString("content") else {
            call.reject("Missing parameters")
            return
        }
        let insight = Insight(id: UUID().uuidString, title: title, content: content, timestamp: ISO8601DateFormatter().string(from: Date()), severity: call.getString("severity") ?? "info")
        InsightStorage.shared.saveInsight(insight)
        call.resolve(["saved": true])
    }
}

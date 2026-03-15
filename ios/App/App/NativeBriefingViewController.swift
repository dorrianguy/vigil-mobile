import UIKit

struct Insight: Codable {
    let id: String
    let title: String
    let content: String
    let timestamp: String
    let severity: String
}

class InsightStorage {
    static let shared = InsightStorage()
    private let defaults = UserDefaults.standard

    func getInsights() -> [Insight] {
        guard let data = defaults.data(forKey: "vigil_insights"),
              let insights = try? JSONDecoder().decode([Insight].self, from: data) else { return [] }
        return insights
    }

    func saveInsight(_ insight: Insight) {
        var insights = getInsights()
        insights.insert(insight, at: 0)
        if insights.count > 50 { insights = Array(insights.prefix(50)) }
        if let data = try? JSONEncoder().encode(insights) { defaults.set(data, forKey: "vigil_insights") }
    }
}

class NativeBriefingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var briefingTitle: String = "Morning Brief"
    private var insights: [Insight] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerView = UIView()
    private let closeButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
        setupHeader()
        setupTableView()
        loadSampleInsights()
    }

    private func setupHeader() {
        headerView.backgroundColor = UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white.withAlphaComponent(0.7)
        closeButton.addTarget(self, action: #selector(dismissBriefing), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closeButton)

        titleLabel.text = briefingTitle
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        subtitleLabel.text = formatter.string(from: Date())
        subtitleLabel.textColor = UIColor(red: 0.37, green: 0.51, blue: 0.97, alpha: 1.0)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 110),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: subtitleLabel.topAnchor, constant: -4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -14),
        ])
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InsightCell.self, forCellReuseIdentifier: "InsightCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func loadSampleInsights() {
        insights = InsightStorage.shared.getInsights()
        if insights.isEmpty {
            insights = [
                Insight(id: "1", title: "Revenue Forecast Alert", content: "Q2 revenue projection revised upward by 12% based on current pipeline velocity. Recommend accelerating hiring for customer success.", timestamp: ISO8601DateFormatter().string(from: Date()), severity: "success"),
                Insight(id: "2", title: "Supply Chain Risk Detected", content: "Component supplier in Taiwan reporting 3-week delays. Impact on Q3 production estimated at $2.4M. Recommend activating secondary supplier.", timestamp: ISO8601DateFormatter().string(from: Date()), severity: "warning"),
                Insight(id: "3", title: "Competitor Intelligence", content: "Competitor A announced enterprise pricing reduction of 15%. Market share impact modeled at 2-3% over 6 months without response.", timestamp: ISO8601DateFormatter().string(from: Date()), severity: "info"),
            ]
            for insight in insights { InsightStorage.shared.saveInsight(insight) }
        }
        tableView.reloadData()
    }

    @objc private func dismissBriefing() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss(animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { insights.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InsightCell", for: indexPath) as! InsightCell
        cell.configure(with: insights[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { "Today's Insights" }
}

class InsightCell: UITableViewCell {
    private let severityDot = UIView()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(red: 0.1, green: 0.13, blue: 0.22, alpha: 1.0)
        selectionStyle = .none

        severityDot.layer.cornerRadius = 5
        severityDot.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(severityDot)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .white.withAlphaComponent(0.7)
        contentLabel.numberOfLines = 3
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentLabel)

        NSLayoutConstraint.activate([
            severityDot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            severityDot.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            severityDot.widthAnchor.constraint(equalToConstant: 10),
            severityDot.heightAnchor.constraint(equalToConstant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: severityDot.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            contentLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            contentLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with insight: Insight) {
        titleLabel.text = insight.title
        contentLabel.text = insight.content
        switch insight.severity {
        case "warning": severityDot.backgroundColor = UIColor(red: 1, green: 0.76, blue: 0.03, alpha: 1)
        case "success": severityDot.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1)
        case "error": severityDot.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 1)
        default: severityDot.backgroundColor = UIColor(red: 0.37, green: 0.51, blue: 0.97, alpha: 1)
        }
    }
}

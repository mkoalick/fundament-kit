import SwiftUI
import ServiceManagement

// Settings window: every option of the strip, applied live, with a preview
// of the chips at the top. Changes are written straight to the settings file.
final class SettingsModel: ObservableObject {
    struct RepoInfo: Identifiable, Equatable {
        let id: String
        let reported: String?
    }

    let store: SettingsStore
    @Published var settings: BarSettings {
        didSet { if settings != store.current { store.update { $0 = settings } } }
    }
    @Published var repos: [RepoInfo] = []
    @Published var notificationsAllowed = false
    @Published var selectedTab: SettingsTab = .appearance
    @Published var hookState: ClaudeHookInstaller.State = .notInstalled
    @Published var hookMessage = ""
    @Published var launchAtLogin = SMAppService.mainApp.status == .enabled
    @Published var loginMessage = ""
    var helperPath = ""
    var settingsPath = "~/.claude/settings.json"
    var sendTestHint: () -> Void = {}
    var requestNotifications: () -> Void = {}
    var revealFile: () -> Void = {}
    var installHooks: (Bool) -> Void = { _ in }

    // Login item through macOS (System Settings › General › Login Items).
    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            loginMessage = ""
        } catch {
            loginMessage = error.localizedDescription
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    init(store: SettingsStore) {
        self.store = store
        settings = store.current
    }

    // Repos seen in the current sessions plus every repo with own settings.
    func updateRepos(_ sessions: [SessionDisplay]) {
        var reported: [String: String] = [:]
        var names = Set(settings.repos.keys)
        for session in sessions {
            names.insert(session.repo)
            if let color = session.repoColor { reported[session.repo] = color }
        }
        let list = names.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
            .map { RepoInfo(id: $0, reported: reported[$0]) }
        if list != repos { repos = list }
    }

    func statusColor(_ key: String) -> Binding<Color> {
        Binding(
            get: { Color(nsColor: NSColor(hex: self.settings.statusColors[key] ?? "") ?? .systemGray) },
            set: { self.settings.statusColors[key] = NSColor($0).hexString })
    }

    func repoColor(_ repo: RepoInfo) -> Binding<Color> {
        Binding(
            get: { Color(nsColor: self.settings.repoColor(repo.id, reported: repo.reported)) },
            set: { self.settings.repos[repo.id, default: .init()].color = NSColor($0).hexString })
    }

    func abbreviation(_ repo: String) -> Binding<String> {
        Binding(
            get: { self.settings.repos[repo]?.abbreviation ?? "" },
            set: { value in
                let trimmed = String(value.trimmingCharacters(in: .whitespaces).prefix(3)).uppercased()
                self.settings.repos[repo, default: .init()].abbreviation = trimmed.isEmpty ? nil : trimmed
            })
    }

    // Kept as short as the settings file allows, also while typing.
    var menuBarLabel: Binding<String> {
        Binding(get: { self.settings.menuBarLabel },
                set: { self.settings.menuBarLabel = String($0.prefix(6)) })
    }

    func visible(_ repo: String) -> Binding<Bool> {
        Binding(
            get: { !(self.settings.repos[repo]?.hidden ?? false) },
            set: { self.settings.repos[repo, default: .init()].hidden = !$0 })
    }
}

enum SettingsTab: Hashable { case appearance, colors, repos, sources, behaviour }

struct SettingsView: View {
    @ObservedObject var model: SettingsModel

    var body: some View {
        TabView(selection: $model.selectedTab) {
            appearance.tabItem { Label("Appearance", systemImage: "rectangle.topthird.inset.filled") }.tag(SettingsTab.appearance)
            colors.tabItem { Label("Colors", systemImage: "paintpalette") }.tag(SettingsTab.colors)
            repos.tabItem { Label("Repos", systemImage: "folder") }.tag(SettingsTab.repos)
            sources.tabItem { Label("Sources", systemImage: "point.3.connected.trianglepath.dotted") }.tag(SettingsTab.sources)
            behaviour.tabItem { Label("Behaviour", systemImage: "gearshape") }.tag(SettingsTab.behaviour)
        }
        .frame(width: 560, height: 600)
    }

    private var appearance: some View {
        Form {
            Section { StripPreview(settings: model.settings) }
            Section("Chips") {
                Picker("Style", selection: $model.settings.style) {
                    Text("Calm").tag(BarSettings.ChipStyle.calm)
                    Text("Bold").tag(BarSettings.ChipStyle.bold)
                }
                .pickerStyle(.segmented)
                Text(model.settings.style == .calm
                     ? "Only sessions waiting for you are filled with color. All others carry a status dot."
                     : "Every chip is filled in its status color.")
                    .font(.callout).foregroundStyle(.secondary)
                Stepper("Font size: \(Int(model.settings.fontSize)) pt", value: $model.settings.fontSize, in: 10...13, step: 1)
                Toggle("Show model badge (C Claude, G Codex, M MiniMax)", isOn: $model.settings.showModelBadge)
                Toggle("Pulse sessions that are waiting", isOn: $model.settings.pulseInput)
                TextField("Menu bar label", text: model.menuBarLabel, prompt: Text("Icon"))
            }
            Section("Strip") {
                Picker("At most", selection: $model.settings.maxRows) {
                    Text("1 row").tag(1)
                    Text("2 rows").tag(2)
                }
                .pickerStyle(.segmented)
                Picker("Repository label", selection: $model.settings.repoLabel) {
                    Text("Abbreviation").tag(BarSettings.RepoLabel.abbreviation)
                    Text("Stripe only").tag(BarSettings.RepoLabel.stripe)
                }
                .pickerStyle(.segmented)
                Picker("Screen", selection: $model.settings.screen) {
                    Text("Largest").tag(BarSettings.ScreenChoice.largest)
                    Text("Main screen").tag(BarSettings.ScreenChoice.main)
                }
                .pickerStyle(.segmented)
            }
        }
        .formStyle(.grouped)
    }

    private var colors: some View {
        Form {
            Section { StripPreview(settings: model.settings) }
            Section("Status colors") {
                ColorPicker("Waiting for you", selection: model.statusColor("waiting"), supportsOpacity: false)
                ColorPicker("Working", selection: model.statusColor("working"), supportsOpacity: false)
                ColorPicker("Done", selection: model.statusColor("done"), supportsOpacity: false)
                ColorPicker("Blocked", selection: model.statusColor("blocked"), supportsOpacity: false)
                ColorPicker("Unclear", selection: model.statusColor("unknown"), supportsOpacity: false)
            }
            Section {
                Button("Restore default colors") { model.settings.statusColors = BarSettings.defaultStatusColors }
                    .disabled(model.settings.statusColors == BarSettings.defaultStatusColors)
            } footer: {
                Text("The chip's text automatically picks black or white, whichever reads better against the color.")
            }
        }
        .formStyle(.grouped)
    }

    private var repos: some View {
        Form {
            Section {
                if model.repos.isEmpty {
                    Text("No repositories yet. They appear here once a session is running.").foregroundStyle(.secondary)
                }
                ForEach(model.repos) { repo in
                    HStack(spacing: 10) {
                        ColorPicker("Color for \(repo.id)", selection: model.repoColor(repo), supportsOpacity: false).labelsHidden()
                        Text(repo.id).lineLimit(1).truncationMode(.middle).frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Abbreviation", text: model.abbreviation(repo.id), prompt: Text(repoAbbreviation(repo.id)))
                            .labelsHidden().frame(width: 54).multilineTextAlignment(.center)
                        Toggle("show", isOn: model.visible(repo.id)).toggleStyle(.checkbox)
                        Button { model.settings.repos[repo.id] = nil } label: { Image(systemName: "arrow.uturn.backward") }
                            .buttonStyle(.borderless).help("Reset to default")
                            .disabled(model.settings.repos[repo.id] == nil)
                    }
                }
            } header: {
                Text("Color, abbreviation, and visibility per repository")
            } footer: {
                Text("Without its own color, a repository uses whatever the collector reports, else gray. Hidden repositories are missing only from the strip; the menu and notifications still show them.")
            }
        }
        .formStyle(.grouped)
    }

    private var hookStateText: String {
        switch model.hookState {
        case .installed: return L("Hooks installed")
        case .outdated: return L("Hooks need an update (the app was moved or updated)")
        case .notInstalled: return L("Hooks not installed")
        }
    }

    private var sources: some View {
        Form {
            Section("Claude Code") {
                Toggle("Show Claude Code sessions", isOn: $model.settings.watchClaude)
                Label(hookStateText, systemImage: model.hookState == .installed ? "checkmark.circle.fill" : "exclamationmark.circle")
                    .foregroundStyle(model.hookState == .installed ? Color.secondary : Color.orange)
                Text("Hooks tell the app when a session starts, works, asks you something, and ends. Installing adds entries to \(model.settingsPath). Your own hooks stay as they are, and the previous file is kept as a backup.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button(model.hookState == .outdated ? "Update hooks" : "Install hooks") { model.installHooks(true) }
                        .disabled(model.hookState == .installed)
                    Button("Remove hooks") { model.installHooks(false) }
                        .disabled(model.hookState == .notInstalled)
                }
                if !model.hookMessage.isEmpty {
                    Text(model.hookMessage).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
                }
                Toggle("Also read Claude's internal session list", isOn: $model.settings.useClaudeRegistry)
                Text("Undocumented and therefore only a fallback: it covers sessions started before the hooks and the moment a permission is granted.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Section("Codex") {
                Toggle("Show Codex sessions (CLI and VS Code)", isOn: $model.settings.watchCodex)
                Text("Codex sessions are read from the files Codex writes; the app checks which of them a running Codex process has open. codex exec runs are not shown.")
                    .font(.callout).foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }

    private var behaviour: some View {
        Form {
            Section("Strip") {
                Toggle("Show the strip below the menu bar", isOn: $model.settings.showBar)
                Picker("Placement", selection: $model.settings.placement) {
                    Text("Push windows below the strip").tag(BarSettings.Placement.makeRoom)
                    Text("Float above windows").tag(BarSettings.Placement.floating)
                }
                Text(model.settings.placement == .makeRoom
                     ? "Needs the Accessibility permission. Windows move down to clear the strip and return to their place when this is switched off."
                     : "Needs no special permission; the strip simply sits on top of the windows' upper edge.")
                    .font(.callout).foregroundStyle(.secondary)
                Stepper("Back to one row after \(Int(model.settings.shrinkDelayMinutes)) min", value: $model.settings.shrinkDelayMinutes, in: 0...30, step: 1)
                Toggle("Open at login", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) }))
                if !model.loginMessage.isEmpty {
                    Text(model.loginMessage).font(.caption).foregroundStyle(.secondary)
                }
            }
            Section("Notifications") {
                Toggle("macOS notifications for Needs You and Done", isOn: $model.settings.nativeNotifications)
                Stepper("Done notice only after \(Int(model.settings.readyHintAfterSeconds)) s of work", value: $model.settings.readyHintAfterSeconds, in: 0...600, step: 15)
                Toggle("Your own 3-second hints on the strip", isOn: $model.settings.popupHints)
                HStack {
                    Button("Send test notification") { model.sendTestHint() }
                    if !model.notificationsAllowed {
                        Button("Allow notifications …") { model.requestNotifications() }
                    }
                }
            }
            Section("Advanced") {
                TextField("Web overview", text: $model.settings.overviewURL, prompt: Text("optional, https://…"))
                HStack {
                    Text(model.store.url.path).font(.caption.monospaced()).foregroundStyle(.secondary)
                        .lineLimit(1).truncationMode(.middle)
                    Spacer()
                    Button("Show file") { model.revealFile() }
                }
            }
        }
        .formStyle(.grouped)
    }
}

// SwiftUI copy of the strip's chip drawing, close enough to judge colors and style.
struct StripPreview: View {
    struct Sample: Hashable { let state: String, name: String, badge: String }
    struct Group: Hashable { let repo: String, color: String, items: [Sample] }

    let settings: BarSettings
    private let samples: [Group]

    // The default two-group sample is enough to judge colors and style in the
    // Settings window. render-settings supplies a wider, denser sample instead,
    // for a strip.png that actually looks like real everyday use.
    init(settings: BarSettings, samples: [Group]? = nil) {
        self.settings = settings
        self.samples = samples ?? [
            Group(repo: "api-server", color: "#3B7DD8", items: [
                Sample(state: "waiting", name: "Migration", badge: "C"),
                Sample(state: "working", name: "Tests", badge: "G"),
                Sample(state: "done", name: "Rollout", badge: "C")]),
            Group(repo: "web-app", color: "#2F9E8F", items: [
                Sample(state: "blocked", name: "Packages", badge: "M")])
        ]
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(samples, id: \.self) { group in
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 1.5).fill(Color(nsColor: settings.repoColor(group.repo, reported: group.color)))
                        .frame(width: 3, height: 12)
                    if settings.repoLabel == .abbreviation {
                        Text(settings.abbreviation(for: group.repo)).font(.system(size: 9, weight: .semibold)).foregroundStyle(.secondary)
                            .frame(width: 18, alignment: .leading)
                    }
                    ForEach(group.items, id: \.self) { item in chip(item.state, item.name, item.badge) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .frame(height: 30)
        .background(RoundedRectangle(cornerRadius: 6).fill(.bar))
        .accessibilityLabel(Text("Preview of the strip"))
    }

    private func chip(_ state: String, _ name: String, _ badge: String) -> some View {
        let status = SessionAppearance.colorFor(state, in: settings)
        let filled = settings.style == .bold || state == "waiting"
        let quiet = !filled && (state == "done" || state == "unknown")
        let text: Color = filled ? Color(nsColor: status.readableText) : (quiet ? .secondary : .primary)
        return HStack(spacing: 5) {
            if settings.style == .calm {
                Circle().fill(filled ? text : Color(nsColor: status)).frame(width: 7, height: 7)
            } else if settings.showModelBadge {
                Text(badge).font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            Text(name).font(.system(size: settings.fontSize, weight: .medium)).lineLimit(1).fixedSize()
            if settings.style == .calm && settings.showModelBadge {
                Text(badge).font(.system(size: 9, weight: .semibold, design: .monospaced)).opacity(0.55)
            }
        }
        .foregroundStyle(text)
        .padding(.horizontal, 8)
        .frame(height: 22)
        .background(RoundedRectangle(cornerRadius: 6).fill(filled ? Color(nsColor: status) : Color.primary.opacity(0.07)))
        .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color(nsColor: status), lineWidth: state == "blocked" && !filled ? 1 : 0))
    }
}

final class SettingsWindowController: NSWindowController {
    let model: SettingsModel

    init(model: SettingsModel) {
        self.model = model
        let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(model: model)))
        window.title = String(format: L("%@ · Settings"), AppIdentity.displayName)
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    required init?(coder: NSCoder) { nil }

    // Opened only from an explicit menu action, so taking focus is intended.
    func present() {
        if window?.isVisible != true { window?.center() }
        if #available(macOS 14, *) { NSApp.activate() } else { NSApp.activate(ignoringOtherApps: true) }
        window?.makeKeyAndOrderFront(nil)
    }
}

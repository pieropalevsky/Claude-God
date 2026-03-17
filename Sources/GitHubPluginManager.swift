// GitHubPluginManager.swift
// Reads GitHub MCP plugin configuration and displays available tools

import Foundation

// MARK: - Models

struct GitHubTool: Identifiable {
    let name: String
    let description: String
    let category: String
    var id: String { name }

    var displayName: String {
        name.replacingOccurrences(of: "_", with: " ").capitalized
    }

    var icon: String {
        switch category {
        case "Pull Requests": return "arrow.triangle.pull"
        case "Issues": return "exclamationmark.circle"
        case "Search": return "magnifyingglass"
        case "Files": return "doc.text"
        case "Repository": return "folder"
        case "History": return "clock"
        default: return "wrench"
        }
    }
}

// MARK: - Manager

class GitHubPluginManager: ObservableObject {

    @Published var isInstalled = false
    @Published var isAuthenticated = false
    @Published var tools: [GitHubTool] = []
    @Published var categories: [String] = []

    func refresh() {
        let result = Self.loadData()
        isInstalled = result.isInstalled
        isAuthenticated = result.isAuthenticated
        tools = result.tools
        categories = Array(Set(result.tools.map(\.category))).sorted()
    }

    private struct LoadResult {
        let isInstalled: Bool
        let isAuthenticated: Bool
        let tools: [GitHubTool]
    }

    private static func loadData() -> LoadResult {
        guard findPluginPath() != nil else {
            return LoadResult(isInstalled: false, isAuthenticated: false, tools: [])
        }

        let hasToken = ProcessInfo.processInfo.environment["GITHUB_PERSONAL_ACCESS_TOKEN"] != nil
            || checkGitHubTokenInConfig()

        let tools = buildToolList()
        return LoadResult(isInstalled: true, isAuthenticated: hasToken, tools: tools)
    }

    private static func findPluginPath() -> String? {
        let pluginsDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/plugins/cache/claude-plugins-official/github")
            .path
        guard let versions = try? FileManager.default.contentsOfDirectory(atPath: pluginsDir) else { return nil }
        let sorted = versions.filter { !$0.hasPrefix(".") }.sorted()
        guard let latest = sorted.last else { return nil }
        return "\(pluginsDir)/\(latest)"
    }

    private static func checkGitHubTokenInConfig() -> Bool {
        // Check ~/.claude.json or ~/.claude/settings.json for GitHub token config
        let paths = [
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude.json"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude/settings.json")
        ]
        for path in paths {
            if let data = try? Data(contentsOf: path),
               let content = String(data: data, encoding: .utf8),
               content.contains("GITHUB_PERSONAL_ACCESS_TOKEN") {
                return true
            }
        }
        return false
    }

    private static func buildToolList() -> [GitHubTool] {
        [
            // Pull Requests
            GitHubTool(name: "create_pull_request", description: "Create a new pull request", category: "Pull Requests"),
            GitHubTool(name: "get_pull_request", description: "Get PR details including diff and review status", category: "Pull Requests"),
            GitHubTool(name: "list_pull_requests", description: "List and filter repository PRs", category: "Pull Requests"),
            GitHubTool(name: "create_pull_request_review", description: "Create reviews on pull requests", category: "Pull Requests"),
            GitHubTool(name: "merge_pull_request", description: "Merge a pull request", category: "Pull Requests"),
            GitHubTool(name: "get_pull_request_files", description: "Get list of files changed in a PR", category: "Pull Requests"),
            GitHubTool(name: "get_pull_request_status", description: "Get combined status of all CI checks", category: "Pull Requests"),
            GitHubTool(name: "update_pull_request_branch", description: "Update PR branch with latest base changes", category: "Pull Requests"),
            GitHubTool(name: "get_pull_request_comments", description: "Retrieve review comments on a PR", category: "Pull Requests"),
            GitHubTool(name: "get_pull_request_reviews", description: "Get reviews on a pull request", category: "Pull Requests"),

            // Issues
            GitHubTool(name: "create_issue", description: "Create a new issue", category: "Issues"),
            GitHubTool(name: "list_issues", description: "List and filter repository issues", category: "Issues"),
            GitHubTool(name: "get_issue", description: "Get issue details", category: "Issues"),
            GitHubTool(name: "update_issue", description: "Update an existing issue", category: "Issues"),
            GitHubTool(name: "add_issue_comment", description: "Add a comment to an issue", category: "Issues"),

            // Search
            GitHubTool(name: "search_repositories", description: "Search for GitHub repositories", category: "Search"),
            GitHubTool(name: "search_code", description: "Search for code across GitHub", category: "Search"),
            GitHubTool(name: "search_issues", description: "Search for issues and PRs", category: "Search"),
            GitHubTool(name: "search_users", description: "Search for GitHub users", category: "Search"),

            // Files
            GitHubTool(name: "create_or_update_file", description: "Create or update a single file", category: "Files"),
            GitHubTool(name: "push_files", description: "Push multiple files in a single commit", category: "Files"),
            GitHubTool(name: "get_file_contents", description: "Get file or directory contents", category: "Files"),

            // Repository
            GitHubTool(name: "create_repository", description: "Create a new GitHub repository", category: "Repository"),
            GitHubTool(name: "fork_repository", description: "Fork a repository", category: "Repository"),
            GitHubTool(name: "create_branch", description: "Create a new branch", category: "Repository"),

            // History
            GitHubTool(name: "list_commits", description: "Get commits of a branch", category: "History"),
        ]
    }
}

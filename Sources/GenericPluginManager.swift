// GenericPluginManager.swift
// Generic plugin detail view data for plugins that are skill-based, LSP, or simple MCP servers

import Foundation

// MARK: - Models

struct PluginDetail {
    let name: String
    let description: String
    let type: PluginType
    let features: [PluginFeature]
    let isInstalled: Bool
    let version: String

    enum PluginType: String {
        case skill = "Skill"
        case lsp = "Language Server"
        case mcp = "MCP Server"
    }
}

struct PluginFeature: Identifiable {
    let name: String
    let description: String
    let icon: String
    var id: String { name }
}

// MARK: - Manager

class GenericPluginManager: ObservableObject {

    @Published var details: [String: PluginDetail] = [:]

    func refresh() {
        var result: [String: PluginDetail] = [:]

        result["swift-lsp@claude-plugins-official"] = loadSwiftLSP()
        result["code-review@claude-plugins-official"] = loadCodeReview()
        result["code-simplifier@claude-plugins-official"] = loadCodeSimplifier()
        result["context7@claude-plugins-official"] = loadContext7()
        result["playwright@claude-plugins-official"] = loadPlaywright()

        details = result
    }

    func detail(for pluginId: String) -> PluginDetail? {
        details[pluginId]
    }

    // MARK: - Swift LSP

    private func loadSwiftLSP() -> PluginDetail {
        let installed = Self.isPluginInstalled("swift-lsp", marketplace: "claude-plugins-official")
        let hasSourceKit = FileManager.default.fileExists(atPath: "/usr/bin/sourcekit-lsp")
            || Self.commandExists("sourcekit-lsp")

        return PluginDetail(
            name: "swift-lsp",
            description: "Swift language server (SourceKit-LSP) for code intelligence and analysis",
            type: .lsp,
            features: [
                PluginFeature(name: "Code Completion", description: "Context-aware Swift completions", icon: "text.cursor"),
                PluginFeature(name: "Go to Definition", description: "Jump to symbol definitions", icon: "arrow.right.circle"),
                PluginFeature(name: "Hover Info", description: "Type information on hover", icon: "info.circle"),
                PluginFeature(name: "Diagnostics", description: "Real-time error and warning detection", icon: "exclamationmark.triangle"),
                PluginFeature(
                    name: "SourceKit-LSP",
                    description: hasSourceKit ? "Found on system" : "Not found — install Swift toolchain",
                    icon: hasSourceKit ? "checkmark.circle.fill" : "xmark.circle"
                ),
            ],
            isInstalled: installed,
            version: "1.0.0"
        )
    }

    // MARK: - Code Review

    private func loadCodeReview() -> PluginDetail {
        let installed = Self.isPluginInstalled("code-review", marketplace: "claude-plugins-official")

        return PluginDetail(
            name: "code-review",
            description: "Automated code review for pull requests using multiple specialized agents",
            type: .skill,
            features: [
                PluginFeature(name: "Security Review", description: "Identifies security vulnerabilities and risks", icon: "shield.checkered"),
                PluginFeature(name: "Performance Review", description: "Detects performance bottlenecks", icon: "gauge.with.dots.needle.33percent"),
                PluginFeature(name: "Code Quality", description: "Checks for best practices and clean code", icon: "star"),
                PluginFeature(name: "Test Coverage", description: "Reviews test completeness", icon: "checklist"),
                PluginFeature(name: "Multi-Agent", description: "Specialized agents for different review aspects", icon: "person.3"),
            ],
            isInstalled: installed,
            version: "1.0.0"
        )
    }

    // MARK: - Code Simplifier

    private func loadCodeSimplifier() -> PluginDetail {
        let installed = Self.isPluginInstalled("code-simplifier", marketplace: "claude-plugins-official")

        return PluginDetail(
            name: "code-simplifier",
            description: "Simplifies and refines code for clarity, consistency, and maintainability",
            type: .skill,
            features: [
                PluginFeature(name: "Remove Complexity", description: "Simplify nested logic, reduce indirection", icon: "arrow.triangle.merge"),
                PluginFeature(name: "Improve Naming", description: "Clearer variable and function names", icon: "textformat.abc"),
                PluginFeature(name: "Reduce Duplication", description: "Extract shared patterns", icon: "doc.on.doc"),
                PluginFeature(name: "Simplify Types", description: "Flatten unnecessary abstractions", icon: "square.stack"),
                PluginFeature(name: "Clean Imports", description: "Remove unused imports and dependencies", icon: "trash"),
            ],
            isInstalled: installed,
            version: "1.0.0"
        )
    }

    // MARK: - Context7

    private func loadContext7() -> PluginDetail {
        let installed = Self.isPluginInstalled("context7", marketplace: "claude-plugins-official")

        return PluginDetail(
            name: "context7",
            description: "Up-to-date documentation lookup for libraries and frameworks via Upstash Context7 MCP",
            type: .mcp,
            features: [
                PluginFeature(name: "Resolve Library", description: "Find library ID from package name", icon: "magnifyingglass"),
                PluginFeature(name: "Get Documentation", description: "Fetch up-to-date docs for any library", icon: "book"),
                PluginFeature(name: "Version-Aware", description: "Always returns current documentation", icon: "clock.arrow.circlepath"),
                PluginFeature(name: "Wide Coverage", description: "Thousands of libraries and frameworks", icon: "globe"),
            ],
            isInstalled: installed,
            version: "1.0.0"
        )
    }

    // MARK: - Playwright

    private func loadPlaywright() -> PluginDetail {
        let installed = Self.isPluginInstalled("playwright", marketplace: "claude-plugins-official")

        return PluginDetail(
            name: "playwright",
            description: "Browser automation and end-to-end testing MCP server by Microsoft",
            type: .mcp,
            features: [
                PluginFeature(name: "Navigate", description: "Open URLs and navigate between pages", icon: "globe"),
                PluginFeature(name: "Interact", description: "Click, type, fill forms, select options", icon: "hand.tap"),
                PluginFeature(name: "Screenshot", description: "Capture page screenshots for visual testing", icon: "camera"),
                PluginFeature(name: "Assert", description: "Verify page content, elements, and state", icon: "checkmark.rectangle"),
                PluginFeature(name: "Network", description: "Intercept and mock network requests", icon: "network"),
                PluginFeature(name: "Multi-Browser", description: "Chromium, Firefox, WebKit support", icon: "square.stack.3d.up"),
            ],
            isInstalled: installed,
            version: "1.0.0"
        )
    }

    // MARK: - Helpers

    private static func isPluginInstalled(_ name: String, marketplace: String) -> Bool {
        let path = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".claude/plugins/cache/claude-plugins-official/\(name)")
            .path
        return FileManager.default.fileExists(atPath: path)
    }

    private static func commandExists(_ cmd: String) -> Bool {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [cmd]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}

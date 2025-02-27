local M = {}

M.main_branches = { "main", "master" }

M.feature_branches = {
    "feature",
    "feat",
    "chore",
    "improvement",
    "enhancement",
    "spike",
    "prototype",
    "experiment",
    "exploration",
    "research",
    "initiative",
    "feature-branch",
    "development",
    "innovation",
    "upgrade",
    "new-feature",
    "epic",
    "story",
}

M.fix_branches = {
    "fix",
    "hotfix",
    "bugfix",
    "patch",
    "bug",
    "fixup",
    "revert",
    "oops",
    "emergency",
    "critical-fix",
    "hot-patch",
    "issue-fix",
    "urgent-fix",
    "bug-correction",
    "error-fix",
    "fault-fix",
    "defect-fix",
    "repair",
    "maintenance",
    "correction",
}

M.misc_branches = {
    "test",
    "refactor",
    "style",
    "docs",
    "misc",
    "release",
    "deploy",
    "build",
    "ci",
    "perf",
    "cleanup",
    "documentation",
    "code-cleanup",
    "config",
    "initial-setup",
    "infrastructure",
    "setup",
    "configuration",
    "admin",
    "support",
    "utility",
    "task",
    "miscellaneous",
    "tools",
    "workflow",
    "automation",
    "changelog",
    "dependencies",
    "meta",
}
M.status_mappings = {
    ["^%sA"] = "staged_added",
    ["^%sM"] = "staged_modified",
    ["^%sD"] = "staged_deleted",
    ["^A%s"] = "added",
    ["^M%s"] = "modified",
    ["^D%s"] = "deleted",
    ["^%?%?"] = "untracked",
    ["^R%s"] = "renamed",
    ["^C%s"] = "copied",
    ["^U%s"] = "unmerged",
    ["^DD"] = "both_deleted",
    ["^AU"] = "added_by_us",
    ["^UD"] = "deleted_by_them",
    ["^UA"] = "added_by_them",
    ["^DU"] = "deleted_by_us",
    ["^AA"] = "both_added",
    ["^UU"] = "both_modified",
    ["^MM"] = { "staged_modified", "modified" },
    ["^MD"] = { "staged_modified", "deleted" },
    ["^AD"] = { "staged_added", "deleted" },
    ["^AM"] = { "staged_added", "modified" },
    ["^RM"] = { "renamed", "modified" },
    ["^RD"] = { "renamed", "deleted" },
}
return M

local vim = vim
local M = {}

function M.check()
	local health = vim.health

	health.start("linescope")

	if vim.fn.has("nvim-0.10") == 1 then
		health.ok("Neovim >= 0.10")
	else
		health.error("Neovim >= 0.10 is required")
	end

	if vim.fn.executable("git") == 1 then
		health.ok("git executable found")
	else
		health.error("git executable not found (git component will not work)")
	end

	if pcall(require, "plenary.job") then
		health.ok("plenary.nvim installed")
	else
		health.error("plenary.nvim not found (required for async git status)")
	end

	if pcall(require, "nvim-web-devicons") then
		health.ok("nvim-web-devicons installed")
	else
		health.info("nvim-web-devicons not found (optional, file icons disabled)")
	end

	if vim.fn.exists("*FugitiveHead") == 1 or pcall(require, "gitsigns") then
		health.ok("vim-fugitive or gitsigns.nvim installed")
	else
		health.info("vim-fugitive/gitsigns.nvim not found (optional, branch name falls back to git)")
	end
end

return M

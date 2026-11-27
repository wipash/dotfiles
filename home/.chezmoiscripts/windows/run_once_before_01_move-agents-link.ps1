# The Home Repo link used to live at ~/AGENTS.md.
$old = Join-Path $HOME 'AGENTS.md'
$new = Join-Path $HOME '.agents\AGENTS.md'

$link = Get-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue
if ($link -and $link.LinkType -eq 'SymbolicLink' -and -not (Get-Item -LiteralPath $new -Force -ErrorAction SilentlyContinue)) {
    New-Item -ItemType Directory -Force -Path (Split-Path $new) | Out-Null
    New-Item -ItemType SymbolicLink -Path $new -Target $link.Target | Out-Null
    Remove-Item -LiteralPath $old
}

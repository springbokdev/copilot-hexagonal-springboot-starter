$ErrorActionPreference = 'Stop'

$branch = git branch --show-current
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to determine the current Git branch.'
}
$changes = git status --short
if ($LASTEXITCODE -ne 0) {
    throw 'Unable to inspect Git working-tree status.'
}

$context = "Branch: $branch"
if ($changes) {
    $context += "`nUncommitted changes:`n$($changes -join "`n")"
} else {
    $context += "`nWorking tree: clean"
}
$context += "`nWorkflow: discover > accept > tdd > review"
[ordered]@{ additionalContext = $context } | ConvertTo-Json -Compress

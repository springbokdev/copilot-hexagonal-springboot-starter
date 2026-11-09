$ErrorActionPreference = 'Stop'

try {
    $event = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $toolName = [string]$event.toolName
    $argsObject = $event.toolArgs
    $serializedArgs = ConvertTo-Json -InputObject $argsObject -Compress -Depth 40
    $command = ''
    $targetPath = ''
    if ($argsObject -is [string]) {
        $command = $argsObject
    } elseif ($null -ne $argsObject) {
        if ($argsObject.PSObject.Properties.Name -contains 'command') {
            $command = [string]$argsObject.command
        } elseif ($argsObject.PSObject.Properties.Name -contains 'script') {
            $command = [string]$argsObject.script
        }
        foreach ($property in @('filePath', 'file_path', 'path', 'targetPath', 'uri')) {
            if ($argsObject.PSObject.Properties.Name -contains $property) {
                $targetPath = [string]$argsObject.$property
                break
            }
        }
    }

    $fileTool = $toolName -in @('edit', 'create', 'write', 'apply_patch', 'str_replace_editor')
    $candidate = $serializedArgs
    if ($fileTool -and $targetPath) {
        $candidate = $targetPath
    }
    if ($toolName -in @('bash', 'powershell')) {
        $candidate = $command
    }
    $sensitive = $candidate -match '(?i)\.env|\.(pem|key|p12|jks|keystore|truststore)([^a-z0-9_]|$)'
    $mutating = $command -match '(?i)(>|sed\s+-i|perl\s+-i|(^|[\s|;])(tee|mv|cp|rm|dd|install|truncate|chmod|chown)([\s]|$)|git\s+(rm|mv|clean|checkout|restore)([\s]|$)|(^|[\s|;])(set-content|out-file|add-content|move-item|copy-item|remove-item|new-item|clear-content|rename-item)([\s]|$))'
    $protected = $candidate -match '(?i)application-prod|application-secrets|\.mvn[/\\]|mvnw|\.github[/\\]workflows|\.github[/\\]hooks|\.git[/\\]|dockerfile|docker-compose'

    if ($sensitive) {
        [ordered]@{
            permissionDecision = 'deny'
            permissionDecisionReason = 'Sensitive environment or key material must not be accessed by an agent tool.'
        } | ConvertTo-Json -Compress
    } elseif (($fileTool -or $mutating) -and $protected) {
        [ordered]@{
            permissionDecision = 'deny'
            permissionDecisionReason = 'Changes to protected build, deployment, hook, or version-control paths are blocked.'
        } | ConvertTo-Json -Compress
    }
} catch {
    [Console]::Error.WriteLine("Unable to evaluate protected-path hook input: $($_.Exception.Message)")
    exit 1
}

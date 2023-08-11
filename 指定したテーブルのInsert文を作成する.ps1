[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")

#設定情報
$serverName = 'インスタンス名'
$databaseName = "データベース名"
$username = "ユーザ"
$password = "パスワード"
$scriptDir = "フォルダ名"
$targetTbl = "テーブル名"

#スクリプト作成のオプション設定
$scripter = new-object Microsoft.SqlServer.Management.Smo.Scripter $serverName
$scripter.Options.ScriptSchema = $false; 
$scripter.Options.ScriptData = $true; 
$scripter.Options.NoCommandTerminator = $true; 
$scripter.Options.ToFileOnly = $true 

#接続確立
$server = new-object Microsoft.SqlServer.Management.Smo.Server $serverName
$server.ConnectionContext.LoginSecure = $false
$server.ConnectionContext.Login = $username
$server.ConnectionContext.password = $password

#出力選択
$db  = $server.Databases[$databaseName]
$tbl = $db.Tables | Where-object {$_.name -eq $targetTbl} 

#ファイル出力
foreach ($s in $tbl) { 
    $tableName = $s.Name
    #write-host $s "$scriptDir\$tableName.sql"
    $scripter.Options.FileName = "$scriptDir\$tableName.sql"          #出力先ファイル
    $scripter.EnumScript($s.Urn)
} 


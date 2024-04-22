function Execute-SQLQuery {
    param(
        [parameter(Mandatory=$true)]
        [string]
        $serverName,
        [parameter(Mandatory=$true)]
        [string]
        $databaseName,
        [parameter(Mandatory=$true)]
        [string]
        $username,
        [parameter(Mandatory=$true)]
        [string]
        $password,
        [string]
        $query
    )

    if (-not $query) {
        Write-Host "クエリを指定してください。"
        return
    }

    # SQL Serverに接続
    $connectionString = "Server=$serverName;Database=$databaseName;User ID=$username;Password=$password;"
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    try {
        # SQLクエリの実行
        $command = $connection.CreateCommand()
        $command.CommandText = $query

        # 結果の取得
        $reader = $command.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($reader)

        # 接続を閉じる
        $connection.Close()

        # 結果を返す
        return $table
    }
    catch {
        Write-Host "エラーが発生しました: $_.Exception.Message"
    }
    finally {
        if ($connection.State -ne 'Closed') {
            $connection.Close()
        }
    }
}

# CSVファイルからヘッダー行を読み取り、CREATE TABLE文を出力する関数
function Get-SqlCreateStatement {
    param(
        [parameter(Mandatory=$true)]
        [string]
        $CsvFilePath,
        [string]
        $OutputFilePath,
        [string]
        $TableName
    )

    # テーブル名が空の場合、CSVファイルパスのファイル名とする
    if($TableName -eq ""){
        $TableName = [System.IO.Path]::GetFileNameWithoutExtension($CsvFilePath)
    }
    # 出力ファイルパスが空の場合、CSVファイルパスのファイル名とする
    if($OutputFilePath -eq ""){
        $OutputFilePath = (Split-Path $CsvFilePath -Parent) +"\"+ ( [System.IO.Path]::GetFileNameWithoutExtension($CsvFilePath)) + ".sql"
    }


    $csvData = Import-Csv -Path $CsvFilePath -Encoding "Default" | Select-Object -First 1

    $columns = @()
    foreach ($property in $csvData.psobject.Properties) {
        $columnName = $property.Name
        $columnType = "VARCHAR(MAX)"  # デフォルトのデータ型

        # 1行目のデータを見て、型が判断できそうなら、条件分岐を追加してください
        #if ($property.Value -as [int]) {
        #    $columnType = "INT"
        #}
        #elseif ($property.Value -as [double]) {
        #    $columnType = "FLOAT"
        #}

        $column = "[{0}] {1}" -f $columnName, $columnType
        $columns += $column
    }

    $sqlColumns = $columns -join ", `r`n    "
    $sql ="IF EXISTS (`r`nSELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[$TableName]')	AND type IN (N'U'))`r`n	DROP TABLE [dbo].[$TableName]`r`nGO"
    $sql = $sql + "`r`nCREATE TABLE [$TableName] (`r`n    $sqlColumns`r`n)`r`nGO"
    # BOMを削除してUTF-8で保存
    $Utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($OutputFilePath, $sql, $Utf8NoBOMEncoding)
    Write-Host $CsvFilePath "のCREATE文を、" $CsvFilePath "に出力しました。"
}
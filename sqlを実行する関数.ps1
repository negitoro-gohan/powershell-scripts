function Execute-SQLQuery {
    param(
        [string]$serverName = "デフォルトのサーバー名",
        [string]$databaseName = "デフォルトのデータベース名",
        [string]$username = "デフォルトのユーザー名",
        [string]$password = "デフォルトのパスワード",
        [string]$query
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

# 関数の呼び出し例 (接続情報を指定せずにクエリだけ指定)
$result = Execute-SQLQuery -query "SELECT * FROM YourTableName"
$result | Format-Table -AutoSize

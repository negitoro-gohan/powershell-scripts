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


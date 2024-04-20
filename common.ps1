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
        Write-Host "�N�G�����w�肵�Ă��������B"
        return
    }

    # SQL Server�ɐڑ�
    $connectionString = "Server=$serverName;Database=$databaseName;User ID=$username;Password=$password;"
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()

    try {
        # SQL�N�G���̎��s
        $command = $connection.CreateCommand()
        $command.CommandText = $query

        # ���ʂ̎擾
        $reader = $command.ExecuteReader()
        $table = New-Object System.Data.DataTable
        $table.Load($reader)

        # �ڑ������
        $connection.Close()

        # ���ʂ�Ԃ�
        return $table
    }
    catch {
        Write-Host "�G���[���������܂���: $_.Exception.Message"
    }
    finally {
        if ($connection.State -ne 'Closed') {
            $connection.Close()
        }
    }
}


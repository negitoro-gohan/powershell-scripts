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

# CSV�t�@�C������w�b�_�[�s��ǂݎ��ACREATE TABLE�����o�͂���֐�
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

    # �e�[�u��������̏ꍇ�ACSV�t�@�C���p�X�̃t�@�C�����Ƃ���
    if($TableName -eq ""){
        $TableName = [System.IO.Path]::GetFileNameWithoutExtension($CsvFilePath)
    }
    # �o�̓t�@�C���p�X����̏ꍇ�ACSV�t�@�C���p�X�̃t�@�C�����Ƃ���
    if($OutputFilePath -eq ""){
        $OutputFilePath = (Split-Path $CsvFilePath -Parent) +"\"+ ( [System.IO.Path]::GetFileNameWithoutExtension($CsvFilePath)) + ".sql"
    }


    $csvData = Import-Csv -Path $CsvFilePath -Encoding "Default" | Select-Object -First 1

    $columns = @()
    foreach ($property in $csvData.psobject.Properties) {
        $columnName = $property.Name
        $columnType = "VARCHAR(MAX)"  # �f�t�H���g�̃f�[�^�^

        # 1�s�ڂ̃f�[�^�����āA�^�����f�ł������Ȃ�A���������ǉ����Ă�������
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
    # BOM���폜����UTF-8�ŕۑ�
    $Utf8NoBOMEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($OutputFilePath, $sql, $Utf8NoBOMEncoding)
    Write-Host $CsvFilePath "��CREATE�����A" $CsvFilePath "�ɏo�͂��܂����B"
}
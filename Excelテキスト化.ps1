function outputLog($logString){

  $Now = Get-Date

  # Log 出力文字列に時刻を付加(YYYY/MM/DD HH:MM:SS.MMM $logString)
  $Log = $Now.ToString("yyyy/MM/dd HH:mm:ss.fff") + " "
  $Log += $logString

  # echo させるために出力したログを戻す
  Return $Log
}
<#
ExcelToTSV
概要
 エクセルをTSVに変換する。※1…エクセルの1つめのシートを対象にする。※2…[temp]というシートを一時シートとするので、エクセルの[temp]シートが存在しないことを前提とする。
引数
 targetFile:エクセルのパス,
 outFile:出力するファイル名,
 startRow:TSV化を開始する行番号,
 startCol:TSV化を開始する列番号,
 existsCol:データが記載されているとみなす列番号(TSVに変換する際この列番号に記載されてる値の最大の行番号までをTSVに変換するため、この引数を指定する)
 existsRow:データが記載されているとみなす行番号(TSVに変換する際この行番号に記載されてる値の最大の列番号までをTSVに変換するため、この引数を指定する)
#>
function ExcelToTSV($targetFile, $outFile, $startRow, $startCol, $existsCol, $existsRow) {
  
  # ファイル名の出力
  $OutFile = (Split-Path -Parent $targetFile)+ '\'+ $OutFile
  outputLog ("[" + (Split-Path $targetFile -Leaf) + "]をテキスト化します。")

  # Excelファイルの存在チェック
  if (!(Test-Path $targetFile)) {
    outputLog "ファイルが存在しません。処理を中止します。"
    exit
  }
  
  #対象のEXCELを開き、一時シート追加
  $xl = New-Object -ComObject Excel.Application
  $wb = $xl.Workbooks.Open($targetFile)
  $targetsh = $wb.Worksheets.Add([System.Reflection.Missing]::Value, $wb.Sheets($wb.Sheets.Count))
  $targetsh.name = "temp"
  $sourceSheet = $wb.Worksheets.Item(1) 
  
  # コピー範囲の特定
  #最大行数の特定
  $lastRow = $sourceSheet.Range($sourceSheet.Cells(1000000, $existsCol), $sourceSheet.Cells(1000000, $existsCol)).End([Microsoft.Office.Interop.Excel.XlDirection]::xlUp.value__).Row
  outputLog ('最大行数は' + $lastRow + 'です')
  
  #最大列数の特定
  $lastCol = $sourceSheet.Range($sourceSheet.Cells($existsRow, 10000), $sourceSheet.Cells($existsRow, 10000)).End([Microsoft.Office.Interop.Excel.XlDirection]::xlToLeft.value__).Column
  outputLog ('最大列数は' + $lastCol + 'です')
  
  #出力対象件数の出力
  outputLog ('出力対象データは' + ($lastrow - ($startRow - 1)) + '件です')
  
  # コピー範囲をクリップボードにコピーしてファイル出力
  outputLog ('テキスト化範囲は(' + $startRow + '行,' + $startCol + '列)から(' + $lastrow + '行,' + $lastCol + '列)です')
  $sourceSheet.range($sourceSheet.Cells($startRow, $startCol), $sourceSheet.Cells($lastrow, $lastCol)).Borders.LineStyle = 1 #テキスト化範囲に全て空白の列が存在する場合、テキスト化の際に列が削除される。そのため、テキスト化範囲に罫線を付ける
  $SourceRange = $sourceSheet.range($sourceSheet.Cells($startRow, $startCol), $sourceSheet.Cells($lastrow, $lastCol))
  if (!($SourceRange.copy())) {
    outputLog "コピーが失敗しました。"
    $wb.Close()
    $xl.Quit()
    exit
  }
  $Range = $targetsh.Range("A1")
  $targetsh.paste($Range) # 貼り付け
  $targetsh.Activate()
  $xl.DisplayAlerts = $FALSE
  $wb.SaveAs($OutFile , [Microsoft.Office.Interop.Excel.XlFileFormat]::xlUnicodeText)  #ファイル出力
  $wb.Close()
  $xl.Quit()

  #デフォルトの文字コードでファイル出力(Windowsの場合デフォルトの文字コードはShift-JIS)
  $data=Get-Content ($OutFile)
  $data | Out-File ($OutFile) -Encoding default 
  outputLog ("[" + (Split-Path $targetFile -Leaf) + "]のテキスト化が完了しました。")


}


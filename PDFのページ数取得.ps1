# DLLファイル名
$dll_name = "PdfSharp.dll"

function script:countPdfPage($filepath) {
    # ファイルが存在しなければ後続処理をスキップ
    if (!(Test-Path $filepath)) {
        return 
    } 

    # 拡張子がPDF以外であれば後続処理をスキップ
    if ((Get-Item $filepath).Extension -ne ".pdf") {
        return 
    }

    $input_pdf = [PdfSharp.Pdf.IO.PdfReader]::Open((Get-Item $filepath).Fullname, [PdfSharp.Pdf.IO.PdfDocumentOpenMode]::Import);
    $page_count = $input_pdf.PageCount
    write-host $page_count
}

# DLLはスクリプトと同階層に置くことを想定しているためカレントパスを取得
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$dll_path = Join-Path $current_path $dll_name
#DLL読み込み
[void][Reflection.Assembly]::LoadFile($dll_path)

Set-Location $current_path

#ファイル読み込み
$rs = Import-Csv import.csv

foreach ($r in $rs) {
	#Write-Host $r       # 行を表示
    countPdfPage $r.file
}
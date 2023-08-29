# DLL�t�@�C����
$dll_name = "PdfSharp.dll"

function script:countPdfPage($filepath) {
    # �t�@�C�������݂��Ȃ���Ό㑱�������X�L�b�v
    if (!(Test-Path $filepath)) {
        return 
    } 

    # �g���q��PDF�ȊO�ł���Ό㑱�������X�L�b�v
    if ((Get-Item $filepath).Extension -ne ".pdf") {
        return 
    }

    $input_pdf = [PdfSharp.Pdf.IO.PdfReader]::Open((Get-Item $filepath).Fullname, [PdfSharp.Pdf.IO.PdfDocumentOpenMode]::Import);
    $page_count = $input_pdf.PageCount
    write-host $page_count
}

# DLL�̓X�N���v�g�Ɠ��K�w�ɒu�����Ƃ�z�肵�Ă��邽�߃J�����g�p�X���擾
$current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
$dll_path = Join-Path $current_path $dll_name
#DLL�ǂݍ���
[void][Reflection.Assembly]::LoadFile($dll_path)

Set-Location $current_path

#�t�@�C���ǂݍ���
$rs = Import-Csv import.csv

foreach ($r in $rs) {
	#Write-Host $r       # �s��\��
    countPdfPage $r.file
}
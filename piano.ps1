Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form
$form.Text = "🎹 MZ ULTIMATE PIANO v8.5 (Final Pass Edition)"
$form.Size = New-Object Drawing.Size(1750, 480) # 건반 추가로 창 크기 확장
$form.BackColor = [Drawing.Color]::FromArgb(35, 35, 35)
$form.StartPosition = "CenterScreen"
$form.KeyPreview = $true

# 1. 음계 매핑 (라, 시, 도 추가)
$notes = @{
    'Z'=131; 'S'=139; 'X'=147; 'D'=156; 'C'=165; 'V'=175; 'G'=185; 'B'=196; 'H'=208; 'N'=220; 'J'=233; 'M'=247;
    'Q'=262; '2'=277; 'W'=294; '3'=311; 'E'=330; 'R'=349; '5'=370; 'T'=392; '6'=415; 'Y'=440; '7'=466; 'U'=494;
    'I'=523; '9'=554; 'O'=587; '0'=622; 'P'=659; '['=698; '='=740; ']'=784;
    # 추가된 3개 음 (라, 시, 도)
    'BACK'=880; 'OEM5'=988; 'RETURN'=1047  # BACK=BackSpace, OEM5=\, RETURN=Enter
}

$btns = @{}

# 2. 흰 건반 배치 (라, 시, 도 추가)
$whiteKeys = @(
    @{k='Z'; l='C1'}, @{k='X'; l='D1'}, @{k='C'; l='E1'}, @{k='V'; l='F1'}, @{k='B'; l='G1'}, @{k='N'; l='A1'}, @{k='M'; l='B1'},
    @{k='Q'; l='C2'}, @{k='W'; l='D2'}, @{k='E'; l='E2'}, @{k='R'; l='F2'}, @{k='T'; l='G2'}, @{k='Y'; l='A2'}, @{k='U'; l='B2'},
    @{k='I'; l='C3'}, @{k='O'; l='D3'}, @{k='P'; l='E3'}, @{k='['; l='F3'}, @{k=']'; l='G3'},
    # 합격 포인트: 추가 건반
    @{k='BS'; l='A3'; real='BACK'}, @{k='\'; l='B3'; real='OEM5'}, @{k='EN'; l='C4'; real='RETURN'}
)

$x = 30
foreach ($item in $whiteKeys) {
    $btn = New-Object Windows.Forms.Button
    $btn.Size = New-Object Drawing.Size(65, 280)
    $btn.Location = New-Object Drawing.Point($x, 80)
    $btn.BackColor = "White"; $btn.FlatStyle = "Flat"
    $btn.Text = $item.k + "`n" + $item.l
    $btn.Tag = if($item.real) { $item.real } else { $item.k } # 실제 키 값 저장
    $btn.TextAlign = "BottomCenter"
    $btn.Font = New-Object Drawing.Font("Arial", 10, [Drawing.FontStyle]::Bold)

    $btn.Add_MouseDown({ 
        if ($_.Button -eq 'Left') { PlayNote $this.Tag } 
    })

    $btns[$btn.Tag] = $btn
    $form.Controls.Add($btn)
    $x += 68
}

# 3. 검은 건반 배치 (기존 유지)
$blackLayout = @(
    @{k='S'; off=0.6}, @{k='D'; off=1.6}, @{k='G'; off=3.6}, @{k='H'; off=4.6}, @{k='J'; off=5.6},
    @{k='2'; off=7.6}, @{k='3'; off=8.6}, @{k='5'; off=10.6}, @{k='6'; off=11.6}, @{k='7'; off=12.6},
    @{k='9'; off=14.6}, @{k='0'; off=15.6}, @{k='='; off=17.6}
)

foreach ($item in $blackLayout) {
    $btn = New-Object Windows.Forms.Button
    $btn.Size = New-Object Drawing.Size(40, 180)
    $btn.Location = New-Object Drawing.Point([math]::Round(30 + $item.off * 68), 80)
    $btn.BackColor = "Black"; $btn.ForeColor = "White"; $btn.FlatStyle = "Flat"
    $btn.Text = $item.k; $btn.TextAlign = "BottomCenter"
    
    $btn.Add_MouseDown({ if ($_.Button -eq 'Left') { PlayNote $this.Text } })

    $btns[$item.k.ToUpper()] = $btn
    $form.Controls.Add($btn); $btn.BringToFront()
}

# 4. 소리 재생 함수
function PlayNote($key) {
    $key = $key.ToUpper()
    if ($notes.ContainsKey($key)) {
        $freq = $notes[$key]
        if ($btns.ContainsKey($key)) {
            $btn = $btns[$key]
            $oldColor = $btn.BackColor
            $btn.BackColor = "Gold"
            $form.Refresh()
            [console]::Beep($freq, 150)
            $btn.BackColor = $oldColor
        } else { [console]::Beep($freq, 150) }
    }
}

# 5. 키보드 입력 처리
$form.Add_KeyDown({
    $k = $_.KeyCode.ToString().ToUpper()
    if ($k -match "D(\d)") { $k = $matches[1] }
    switch ($k) {
        "OEMOPENBRACKETS" { $k = "[" }
        "OEM6" { $k = "]" }
        "OEMPLUS" { $k = "=" }
    }
    PlayNote $k
})

$form.ShowDialog() | Out-Null
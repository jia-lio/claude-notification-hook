# 수정 25.01.02
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 이미지 경로
$imagePath = "$env:USERPROFILE\.claude\claudeImage.png"

# 이미지 크기 가져오기
$img = [System.Drawing.Image]::FromFile($imagePath)
$imgWidth = $img.Width
$imgHeight = $img.Height
$img.Dispose()

# 슬라이드 거리 (이미지 너비 + 여유)
$slideDistance = $imgWidth + 20

# 화면 크기 가져오기
$screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea

# XAML로 윈도우 정의
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Claude Code"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        Topmost="True"
        ShowInTaskbar="False"
        Width="$imgWidth"
        Height="$imgHeight">
    <Border CornerRadius="10" ClipToBounds="True" RenderTransformOrigin="0.5,0.5">
        <Border.RenderTransform>
            <TranslateTransform x:Name="SlideTransform" X="$slideDistance"/>
        </Border.RenderTransform>
        <Grid>
            <Image Source="$imagePath" Stretch="UniformToFill"/>
        </Grid>
    </Border>
</Window>
"@

# XAML 파싱
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# 화면 우측 하단에 위치
$window.Left = $screen.Right - $window.Width - 20
$window.Top = $screen.Bottom - $window.Height - 20

# SlideTransform 찾기
$border = $window.Content
$slideTransform = $border.RenderTransform

# 슬라이드 인 애니메이션
$slideIn = New-Object System.Windows.Media.Animation.DoubleAnimation
$slideIn.From = $slideDistance
$slideIn.To = 0
$slideIn.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(500))
$slideIn.EasingFunction = New-Object System.Windows.Media.Animation.QuadraticEase
$slideIn.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut

# 슬라이드 아웃 애니메이션
$slideOut = New-Object System.Windows.Media.Animation.DoubleAnimation
$slideOut.From = 0
$slideOut.To = $slideDistance
$slideOut.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))
$slideOut.EasingFunction = New-Object System.Windows.Media.Animation.QuadraticEase
$slideOut.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseIn

# 슬라이드 아웃 완료 후 창 닫기
$slideOut.Add_Completed({
    $window.Close()
})

# 3초 후 슬라이드 아웃
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(3)
$timer.Add_Tick({
    $slideTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $slideOut)
    $timer.Stop()
})

# 윈도우 로드 시 슬라이드 인 시작
$window.Add_Loaded({
    $slideTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::XProperty, $slideIn)
    $timer.Start()
})

# 윈도우 표시
$window.ShowDialog() | Out-Null

$path = "C:\xampp\htdocs\Hotel_paradise\frontend-react\src\rooms.tsx"
$content = Get-Content $path -Raw

# Suite
$content = $content -replace "(?s)'Suite': \[.*?\],", @"
'Suite': [
   {group: 'site', name: 'Suite-768x511', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit1', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit2', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit3', position: '50% 45%'},
   {group: 'beds-suit', name: 'suit4', position: '50% 45%'}
  ],
"@

# Family Room
$content = $content -replace "(?s)'Family Room': \[.*?\],", @"
'Family Room': [
   {group: 'site', name: 'DSC_5418-768x512', position: '50% 45%'},
   {group: 'rooms', name: 'family-room', position: '50% 45%'},
   {group: 'rooms', name: 'family-room-2', position: '50% 45%'},
   {group: 'rooms', name: 'family-room-3', position: '50% 45%'}
  ],
"@

# Triple Room
$content = $content -replace "(?s)'Triple Room': \[.*?\],", @"
'Triple Room': [
   {group: 'rooms', name: 'triple-room', position: '50% 45%'},
   {group: 'rooms', name: 'triple-room-2', position: '50% 45%'},
   {group: 'rooms', name: 'triple-room-3', position: '50% 45%'},
   {group: 'beds-triple', name: 'triple-bed', position: '50% 45%'}
  ],
"@

# Executive Deluxe
$content = $content -replace "(?s)'Executive Deluxe': \[.*?\],", @"
'Executive Deluxe': [
   {group: 'site', name: 'executive-deluxe-room', position: '50% 45%'},
   {group: 'beds-exec', name: 'executive-bed1', position: '50% 45%'},
   {group: 'beds-exec', name: 'executive-bed2', position: '50% 45%'},
   {group: 'beds-exec', name: 'executive-bed3', position: '50% 45%'},
   {group: 'beds-exec', name: 'executive-room-window-view', position: '50% 50%'}
  ],
"@

# Standard Single
$content = $content -replace "(?s)'Standard Single': \[.*?\],", @"
'Standard Single': [
   {group: 'site', name: 'Single-Room-768x512', position: '50% 45%'},
   {group: 'rooms', name: 'standard-single', position: '50% 45%'},
   {group: 'rooms', name: 'standard-single-2', position: '50% 45%'}
  ],
"@

# Standard Twin
$content = $content -replace "(?s)'Standard Twin': \[.*?\],", @"
'Standard Twin': [
   {group: 'rooms', name: 'standard-twin', position: '50% 45%'},
   {group: 'rooms', name: 'standard-twin-2', position: '50% 45%'},
   {group: 'beds-twin', name: 'bed1', position: '50% 45%'}
  ],
"@

Set-Content $path -Value $content -Encoding UTF8
Write-Output "done"

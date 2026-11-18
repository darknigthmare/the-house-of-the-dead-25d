@echo off
setlocal
cd /d "%~dp0"
where py >nul 2>nul
if not errorlevel 1 (
  py -3 "Jouer.py"
  if not errorlevel 1 exit /b 0
)
powershell.exe -NoProfile -Command ^
 "$dir=Join-Path (Get-Location) 'site';" ^
 "$server=New-Object System.Net.Sockets.TcpListener([Net.IPAddress]::Loopback,0); $server.Start(); $url='http://127.0.0.1:'+$server.LocalEndpoint.Port+'/';" ^
 "Write-Host 'Dossier Curien'; Write-Host $url; Write-Host 'Gardez cette fenetre ouverte pour jouer. Ctrl+C pour fermer.'; Start-Process $url;" ^
 "$mime=@{'.html'='text/html; charset=utf-8';'.js'='application/javascript';'.wasm'='application/wasm';'.png'='image/png';'.pck'='application/octet-stream'};" ^
 "try { while($true){ $client=$server.AcceptTcpClient(); try { $client.ReceiveTimeout=4000; $stream=$client.GetStream(); $reader=New-Object IO.StreamReader($stream); $line=$reader.ReadLine();" ^
 "if(!$line -or $line -notmatch '^GET /([^ ?]*)[^ ]* HTTP/'){continue}; $name=$Matches[1]; if(!$name){$name='index.html'}; while($reader.ReadLine()){};" ^
 "$good=$name -match '^index\.(html|js|wasm|pck|png|icon\.png|apple-touch-icon\.png|audio\.worklet\.js|audio\.position\.worklet\.js)$';" ^
 "$file=if($good){Join-Path $dir $name}else{''}; $crlf=[char]13+[string][char]10;" ^
 "if(!$file -or !(Test-Path -LiteralPath $file -PathType Leaf)){ $message='HTTP/1.1 404 Not Found'+$crlf+'Content-Length: 0'+$crlf+'Connection: close'+$crlf+$crlf; $head=[Text.Encoding]::ASCII.GetBytes($message); $stream.Write($head,0,$head.Length); continue };" ^
 "$handle=[IO.File]::OpenRead($file); try { $type=$mime[[IO.Path]::GetExtension($name)]; $message='HTTP/1.1 200 OK'+$crlf+'Content-Type: '+$type+$crlf+'Content-Length: '+$handle.Length+$crlf+'Connection: close'+$crlf+$crlf; $head=[Text.Encoding]::ASCII.GetBytes($message); $stream.Write($head,0,$head.Length); $handle.CopyTo($stream) } finally {$handle.Dispose()};" ^
 "} catch [IO.IOException] {} finally {$client.Close()} } } finally {$server.Stop()}"
pause

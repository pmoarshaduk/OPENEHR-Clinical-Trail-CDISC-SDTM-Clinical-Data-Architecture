# Create a clean nginx.conf file
$nginxConfigPath = "C:\Projects\PCOD\docker\ecrf\nginx\nginx.conf"

# Write without BOM using UTF8NoBOM encoding
$nginxContent = @"
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    location /api/ {
        proxy_pass http://host.docker.internal:8080/ehrbase/rest/openehr/v1/;
        proxy_set_header Host `$host;
        proxy_set_header X-Real-IP `$remote_addr;
    }
    
    location / {
        try_files `$uri `$uri/ /index.html;
    }
}
"@

# Remove the file if exists
Remove-Item $nginxConfigPath -Force -ErrorAction SilentlyContinue

# Create new file with UTF8NoBOM
[System.IO.File]::WriteAllText($nginxConfigPath, $nginxContent, [System.Text.UTF8Encoding]::new($false))

Write-Host "✅ Clean nginx.conf created" -ForegroundColor Green
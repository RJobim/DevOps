$ErrorActionPreference = "Stop"

$projectDir = "C:\Users\Renato Jobim\Documents\DevOps\gitops-project"
Set-Location $projectDir

Write-Host "Limpando versão antiga em Python..."
if (Test-Path "app") {
    Remove-Item -Recurse -Force "app"
}

Write-Host "Inicializando o repositório Git e criando branch main..."
git init
git checkout -b main 2>$null
if ($LASTEXITCODE -ne 0) { git checkout -B main }

# Garante que temos um commit inicial na main para poder ramificar
New-Item -ItemType File -Name ".gitignore" -Value "node_modules/`ndist/" -Force | Out-Null
git add .gitignore
git commit -m "chore: initial commit"

Write-Host "Criando nova branch: feat/web-app-ts..."
git checkout -b feat/web-app-ts

Write-Host "Criando Commit 1: Configuração do Projeto..."
New-Item -ItemType Directory -Name "app" -Force | Out-Null
Set-Content -Path "app\package.json" -Value '{
  "name": "gitops-ts-app",
  "version": "1.0.0",
  "scripts": { "build": "tsc" },
  "devDependencies": { "typescript": "^5.0.0" }
}'
Set-Content -Path "app\tsconfig.json" -Value '{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  }
}'
git add app/package.json app/tsconfig.json
git commit -m "feat: add typescript configuration and package.json"

Write-Host "Criando Commit 2: Estrutura HTML..."
New-Item -ItemType Directory -Name "app\src" -Force | Out-Null
Set-Content -Path "app\src\index.html" -Value '<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>App GitOps</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Projeto GitOps</h1>
        <p id="message">Carregando...</p>
    </div>
    <script src="app.js"></script>
</body>
</html>'
git add app/src/index.html
git commit -m "feat: add initial HTML structure"

Write-Host "Criando Commit 3: Estilos CSS..."
Set-Content -Path "app\src\style.css" -Value 'body {
    font-family: sans-serif;
    background-color: #f4f4f9;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
}
.container {
    background: white;
    padding: 2rem;
    border-radius: 8px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    text-align: center;
}
h1 { color: #333; }
#message { color: #0066cc; font-weight: bold; }'
git add app/src/style.css
git commit -m "feat: add styling with CSS"

Write-Host "Criando Commit 4: Lógica TypeScript..."
Set-Content -Path "app\src\app.ts" -Value 'document.addEventListener("DOMContentLoaded", () => {
    const msgElement = document.getElementById("message");
    if (msgElement) {
        msgElement.textContent = "TypeScript rodando com sucesso no nosso ambiente GitOps!";
    }
});'
git add app/src/app.ts
git commit -m "feat: add typescript logic to update UI"

Write-Host "Criando Commit 5: Dockerfile..."
# Dockerfile Multi-stage: Usa o Node para compilar o TS e depois um Nginx leve para servir os arquivos estáticos!
Set-Content -Path "app\Dockerfile" -Value 'FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/src/index.html /usr/share/nginx/html/
COPY --from=builder /app/src/style.css /usr/share/nginx/html/
COPY --from=builder /app/dist/app.js /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]'
git add app/Dockerfile
git commit -m "chore: add multi-stage Dockerfile for nginx deployment"

Write-Host "`n=== PROCESSO CONCLUÍDO ==="
Write-Host "Você está na branch: feat/web-app-ts"
Write-Host "Aqui estão os seus commits:`n"
git log --oneline -n 6

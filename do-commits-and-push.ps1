$ErrorActionPreference = "Stop"

# Garante a branch main e o commit inicial
git checkout -b main
New-Item -ItemType File -Name ".gitignore" -Value "node_modules/`ndist/" -Force | Out-Null
git add .gitignore
git commit -m "chore: initial commit"
git push -u origin main

# Cria a branch para os commits do projeto
git checkout -b feat/web-app-ts

$appDir = "gitops-project"
if (Test-Path "$appDir\app") { Remove-Item -Recurse -Force "$appDir\app" }
New-Item -ItemType Directory -Name "$appDir\app" -Force | Out-Null

# Commit 1
Set-Content -Path "$appDir\app\package.json" -Value '{
  "name": "gitops-ts-app",
  "version": "1.0.0",
  "scripts": { "build": "tsc" },
  "devDependencies": { "typescript": "^5.0.0" }
}'
Set-Content -Path "$appDir\app\tsconfig.json" -Value '{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true
  }
}'
git add "$appDir\app\package.json" "$appDir\app\tsconfig.json"
git commit -m "feat: add typescript configuration and package.json"

# Commit 2
New-Item -ItemType Directory -Name "$appDir\app\src" -Force | Out-Null
Set-Content -Path "$appDir\app\src\index.html" -Value '<!DOCTYPE html>
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
git add "$appDir\app\src\index.html"
git commit -m "feat: add initial HTML structure"

# Commit 3
Set-Content -Path "$appDir\app\src\style.css" -Value 'body {
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
git add "$appDir\app\src\style.css"
git commit -m "feat: add styling with CSS"

# Commit 4
Set-Content -Path "$appDir\app\src\app.ts" -Value 'document.addEventListener("DOMContentLoaded", () => {
    const msgElement = document.getElementById("message");
    if (msgElement) {
        msgElement.textContent = "TypeScript rodando com sucesso no nosso ambiente GitOps!";
    }
});'
git add "$appDir\app\src\app.ts"
git commit -m "feat: add typescript logic to update UI"

# Commit 5
Set-Content -Path "$appDir\app\Dockerfile" -Value 'FROM node:18-alpine AS builder
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
git add "$appDir\app\Dockerfile"
git commit -m "chore: add multi-stage Dockerfile for nginx deployment"

# Envia a nova branch para o repositório remoto
git push -u origin feat/web-app-ts

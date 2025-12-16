# 🚀 Projet DevOps GCP — Flask, Docker, Terraform, GKE, CI/CD

Ce projet démontre une architecture DevOps complète pour déployer une application Flask sur Google Cloud Platform avec Kubernetes, Infrastructure as Code et CI/CD.

## 📋 Sommaire

1. [Architecture du Projet](#-architecture-du-projet)
2. [Prérequis](#-prérequis)
3. [Structure des Fichiers](#-structure-des-fichiers)
4. [Variables à Configurer](#-variables-à-configurer)
5. [Étapes de Déploiement](#-étapes-de-déploiement)
6. [Points Couverts](#-points-couverts)

---

## 🏗 Architecture du Projet

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   GitHub Repo   │────▶│  GitHub Actions  │────▶│ Artifact Registry│
└─────────────────┘     └──────────────────┘     └────────┬────────┘
                                                          │
                        ┌─────────────────────────────────▼─────────┐
                        │              GKE Cluster                  │
                        │  ┌─────────┐  ┌─────────┐                │
                        │  │  Pod 1  │  │  Pod 2  │  (Flask App)   │
                        │  └────┬────┘  └────┬────┘                │
                        │       └──────┬─────┘                     │
                        │         LoadBalancer                     │
                        └─────────────┬───────────────────────────┘
                                      │
                                 Internet
```

---

## 🔧 Prérequis

- Compte Google Cloud Platform avec facturation activée
- Google Cloud SDK installé (`gcloud`)
- Docker installé
- Terraform >= 1.0.0
- kubectl installé
- Compte GitHub

---

## 📁 Structure des Fichiers

```
flask-gcp-project/
├── app/
│   ├── app.py              # Application Flask
│   ├── Dockerfile          # Image Docker
│   └── requirements.txt    # Dépendances Python
├── k8s/
│   ├── deployment.yaml     # Déploiement Kubernetes
│   └── service.yaml        # Service LoadBalancer
├── terraform/
│   ├── main.tf             # Ressources Terraform (IAM, APIs)
│   ├── variables.tf        # Variables Terraform
│   ├── outputs.tf          # Outputs Terraform
│   └── terraform.tfvars.example
├── .github/
│   └── workflows/
│       └── deploy.yml      # Pipeline CI/CD
└── README.md
```

---

## ⚙ Variables à Configurer

### Variables Générales

| Variable | Description | Exemple |
|----------|-------------|---------|
| `PROJECT_ID` | ID de votre projet GCP | `my-gcp-project-123` |
| `REGION` | Région GCP | `europe-west1` |
| `ZONE` | Zone GCP | `europe-west1-b` |

### Secrets GitHub Actions

Configurer dans **Settings > Secrets and variables > Actions** :

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | ID de votre projet GCP |
| `GCP_SA_KEY` | Clé JSON du service account CI/CD |

### Fichiers à Modifier

1. **`k8s/deployment.yaml`** : Remplacer `PROJECT_ID` dans l'image
2. **`terraform/terraform.tfvars`** : Copier depuis `.example` et remplir

---

## 📝 Étapes de Déploiement

### 1️⃣ Configuration GCP Initiale

```bash
# Connexion à GCP
gcloud auth login
gcloud config set project PROJECT_ID

# Activer les APIs nécessaires
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable iam.googleapis.com
```

### 2️⃣ Déployer l'Infrastructure avec Terraform (IAM)

```bash
cd terraform

# Copier et éditer les variables
cp terraform.tfvars.example terraform.tfvars
# Éditer terraform.tfvars avec vos valeurs

# Initialiser et appliquer
terraform init
terraform plan
terraform apply
```

Terraform crée :
- Service Account pour GKE
- Service Account pour CI/CD
- Roles IAM nécessaires
- Repository Artifact Registry
- Activation des APIs

### 3️⃣ Build & Test Local (Docker)

```bash
cd app

# Build de l'image
docker build -t flask-app .

# Test local
docker run -p 8080:8080 flask-app

# Vérifier sur http://localhost:8080
```

### 4️⃣ Push vers Artifact Registry

```bash
# Configurer Docker pour Artifact Registry
gcloud auth configure-docker europe-west1-docker.pkg.dev

# Tag et push
docker tag flask-app europe-west1-docker.pkg.dev/PROJECT_ID/flask-repo/flask-app:latest
docker push europe-west1-docker.pkg.dev/PROJECT_ID/flask-repo/flask-app:latest
```

### 5️⃣ Créer le Cluster GKE (Kubernetes)

```bash
# Créer le cluster
gcloud container clusters create flask-cluster \
  --zone=europe-west1-b \
  --num-nodes=2 \
  --machine-type=e2-small

# Obtenir les credentials
gcloud container clusters get-credentials flask-cluster --zone=europe-west1-b
```

### 6️⃣ Déployer sur Kubernetes

```bash
cd k8s

# Remplacer PROJECT_ID dans deployment.yaml
sed -i 's/PROJECT_ID/your-project-id/g' deployment.yaml

# Appliquer les manifests
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Vérifier le déploiement
kubectl get pods
kubectl get services

# Obtenir l'IP externe
kubectl get service flask-service -w
```

### 7️⃣ Configurer le Pipeline CI/CD (GitHub)

```bash
# Initialiser Git
git init
git add .
git commit -m "Initial commit: Flask GCP DevOps project"

# Lier au repo GitHub
git remote add origin https://github.com/USERNAME/REPO.git
git branch -M main
git push -u origin main
```

Configurer les secrets GitHub :
1. Aller dans **Settings > Secrets and variables > Actions**
2. Ajouter `GCP_PROJECT_ID`
3. Ajouter `GCP_SA_KEY` (contenu JSON de la clé du service account CI/CD)

### Générer la clé du Service Account

```bash
# Créer la clé JSON
gcloud iam service-accounts keys create key.json \
  --iam-account=cicd-service-account@PROJECT_ID.iam.gserviceaccount.com

# Copier le contenu pour GitHub Secrets
cat key.json
```

⚠️ **Ne jamais committer la clé JSON dans Git !**

---

## ✅ Points Couverts

| # | Exigence | Implémentation |
|---|----------|----------------|
| 1 | **Application à déployer** | Flask avec health checks (`app/app.py`) |
| 2 | **Registry Docker** | Google Artifact Registry (`terraform/main.tf`) |
| 3 | **Kubernetes** | GKE avec Deployment + Service (`k8s/`) |
| 4 | **IAM Terraform** | Service Accounts + Roles (`terraform/main.tf`) |
| 5 | **Pipeline CI/CD** | GitHub Actions (`.github/workflows/deploy.yml`) |
| 6 | **Git** | Structure complète avec `.github/` |
| 7 | **README** | Ce fichier documenté |

---

## 🔍 Vérification du Déploiement

```bash
# Vérifier les pods
kubectl get pods -l app=flask

# Vérifier les logs
kubectl logs -l app=flask

# Obtenir l'URL externe
kubectl get service flask-service

# Tester l'application
curl http://EXTERNAL_IP/
curl http://EXTERNAL_IP/health
curl http://EXTERNAL_IP/ready
```

---

## 🧹 Nettoyage

```bash
# Supprimer les ressources Kubernetes
kubectl delete -f k8s/

# Supprimer le cluster GKE
gcloud container clusters delete flask-cluster --zone=europe-west1-b

# Supprimer les ressources Terraform
cd terraform
terraform destroy

# Supprimer les images Docker
gcloud artifacts docker images delete \
  europe-west1-docker.pkg.dev/PROJECT_ID/flask-repo/flask-app --delete-tags
```

---

## 📚 Ressources

- [Documentation GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions pour GCP](https://github.com/google-github-actions)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)

---

## 👤 Auteur

Projet DevOps réalisé dans le cadre d'un exercice de déploiement cloud.

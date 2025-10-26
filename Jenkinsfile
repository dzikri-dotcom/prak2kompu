pipeline {
    agent any

    environment {
        IMAGE_NAME = 'dzikri2811/prak2kompu'          // nama image di Docker Hub
        REGISTRY = 'https://index.docker.io/v1/'
        REGISTRY_CREDENTIALS = 'dockerhub-credentials' // ID credentials Docker Hub di Jenkins
        CONTAINER_NAME = 'prak2kompu_app'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📦 Mengambil source code dari GitHub...'
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '⚙️ Menjalankan Composer install...'
                bat 'composer install --no-dev --optimize-autoloader'

                echo '🧩 Menyalin file .env dari contoh...'
                bat 'if not exist .env copy .env.example .env'

                echo '🔑 Membuat kunci aplikasi Laravel...'
                bat 'php artisan key:generate'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Membuat Docker image Laravel...'
                bat "docker build -t %IMAGE_NAME%:%BUILD_NUMBER% ."
            }
        }

        stage('Push Docker Image') {
            steps {
                echo '☁️ Mengunggah image ke Docker Hub...'
                withCredentials([usernamePassword(
                    credentialsId: REGISTRY_CREDENTIALS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
                    bat "docker push %IMAGE_NAME%:%BUILD_NUMBER%"
                    bat "docker tag %IMAGE_NAME%:%BUILD_NUMBER% %IMAGE_NAME%:latest"
                    bat "docker push %IMAGE_NAME%:latest"
                }
            }
        }

        stage('Run Docker Container (Test)') {
            steps {
                echo '🚀 Menjalankan container Laravel untuk pengujian...'
                bat "docker stop %CONTAINER_NAME% || echo Tidak ada container lama"
                bat "docker rm %CONTAINER_NAME% || echo Tidak ada container lama"
                bat "docker run -d -p 8000:8000 --name %CONTAINER_NAME% %IMAGE_NAME%:latest"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline berhasil dijalankan semua tahap!'
        }
        failure {
            echo '❌ Pipeline gagal, cek log pada tahap sebelumnya.'
        }
        always {
            echo '🏁 Pipeline selesai dijalankan.'
        }
    }
}

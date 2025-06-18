// Jenkinsfile (Declarative Pipeline)
pipeline {
    // Menentukan di mana pipeline akan berjalan. 'any' berarti di agent mana saja yang tersedia.
    agent any

    // Variabel lingkungan untuk digunakan di seluruh pipeline
    environment {
        // Ganti dengan nama user Docker Hub Anda dan nama image
        DOCKER_IMAGE = "your-dockerhub-username/demo-springboot"
        // ID kredensial Docker Hub yang sudah Anda simpan di Jenkins
        DOCKER_CREDENTIALS_ID = "dockerhub-credentials"
    }

    // Tahapan-tahapan yang akan dieksekusi secara berurutan
    stages {
        stage('Checkout') {
            steps {
                echo 'Mengambil kode dari source control...'
                // Ganti dengan URL repository Git Anda
                git url: 'https://github.com/your-username/your-repo.git', branch: 'main'
            }
        }

        stage('Build & Test Application') {
            steps {
                echo 'Membangun aplikasi dengan Maven...'
                // Menggunakan wrapper Maven untuk build dan test
                sh './mvnw clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Membangun Docker image: ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                // Perintah 'docker build' menggunakan Dockerfile di direktori saat ini
                // Tag image dibuat unik dengan nomor build dari Jenkins
                sh "docker build -t ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
            }
        }

        stage('Push Docker Image to Registry') {
            steps {
                echo "Mendorong image ke Docker Hub..."
                // Jenkins akan login ke Docker Hub menggunakan kredensial yang tersimpan
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "echo ${PASSWORD} | docker login -u ${USERNAME} --password-stdin"
                    sh "docker push ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }

        // Tahap 'Deploy' ini adalah placeholder untuk langkah selanjutnya
        stage('Deploy to Kubernetes') {
            steps {
                echo 'Tahap deploy akan dikonfigurasi selanjutnya...'
                echo 'Biasanya di sini kita akan menjalankan "kubectl apply -f k8s/"'
            }
        }
    }

    // Aksi yang dijalankan setelah pipeline selesai (baik sukses maupun gagal)
    post {
        always {
            echo 'Pipeline selesai. Membersihkan...'
            // Menghapus Docker image lokal untuk menghemat ruang
            sh "docker rmi ${env.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
        }
    }
}
pipeline {
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9.4-openjdk-17-slim
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: docker
    image: docker:20.10.24-dind-alpine3.18
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli:latest
    command:
    - cat
    tty: true
  - name: trivy
    image: aquasec/trivy:latest
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
"""
        }
    }
    
    environment {
        // Registry Configuration
        DOCKER_REGISTRY = 'your-registry.com'
        DOCKER_REPOSITORY = 'spring-boot-api'
        IMAGE_TAG = "${BUILD_NUMBER}-${GIT_COMMIT.take(7)}"
        
        // Kubernetes Configuration
        K8S_NAMESPACE_DEV = 'development'
        K8S_NAMESPACE_STAGING = 'staging'
        K8S_NAMESPACE_PROD = 'production'
        
        // SonarQube Configuration
        SONAR_HOST_URL = 'https://sonarqube.your-domain.com'
        
        // Notification Configuration
        SLACK_CHANNEL = '#cicd-notifications'
        
        // Security thresholds
        COVERAGE_THRESHOLD = '80'
        SECURITY_THRESHOLD = 'HIGH'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 60, unit: 'MINUTES')
        skipStagesAfterUnstable()
        ansiColor('xterm')
    }
    
    triggers {
        pollSCM('H/5 * * * *') // Poll every 5 minutes
        githubPush()
    }
    
    stages {
        stage('🏗️ Preparation') {
            steps {
                script {
                    // Clean workspace
                    cleanWs()
                    
                    // Checkout code
                    checkout scm
                    
                    // Set build description
                    currentBuild.description = "Branch: ${env.BRANCH_NAME}, Commit: ${env.GIT_COMMIT.take(7)}"
                }
            }
        }
        
        stage('🔍 Code Quality & Security Analysis') {
            parallel {
                stage('Maven Build & Test') {
                    steps {
                        container('maven') {
                            sh '''
                                echo "🚀 Building and testing application..."
                                mvn clean compile test -B
                                
                                echo "📊 Generating test reports..."
                                mvn jacoco:report
                            '''
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                            publishCoverage adapters: [
                                jacocoAdapter('target/site/jacoco/jacoco.xml')
                            ], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                        }
                    }
                }
                
                stage('SonarQube Analysis') {
                    when {
                        anyOf {
                            branch 'main'
                            branch 'develop'
                            changeRequest()
                        }
                    }
                    steps {
                        container('sonar-scanner') {
                            withSonarQubeEnv('SonarQube') {
                                sh '''
                                    echo "🔍 Running SonarQube analysis..."
                                    sonar-scanner \
                                        -Dsonar.projectKey=spring-boot-api \
                                        -Dsonar.sources=src/main/java \
                                        -Dsonar.tests=src/test/java \
                                        -Dsonar.java.binaries=target/classes \
                                        -Dsonar.junit.reportPaths=target/surefire-reports \
                                        -Dsonar.jacoco.reportPaths=target/site/jacoco/jacoco.xml \
                                        -Dsonar.coverage.exclusions=**/*Application.java,**/*Config.java
                                '''
                            }
                        }
                    }
                }
                
                stage('OWASP Dependency Check') {
                    steps {
                        container('maven') {
                            sh '''
                                echo "🔐 Running OWASP Dependency Check..."
                                mvn org.owasp:dependency-check-maven:check \
                                    -DfailBuildOnAnyVulnerability=false \
                                    -DsuppressionsLocation=owasp-suppressions.xml
                            '''
                        }
                    }
                    post {
                        always {
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: 'target',
                                reportFiles: 'dependency-check-report.html',
                                reportName: 'OWASP Dependency Check Report'
                            ])
                        }
                    }
                }
            }
        }
        
        stage('📈 Quality Gate') {
            steps {
                script {
                    echo "⏳ Waiting for SonarQube Quality Gate..."
                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        
        stage('🏗️ Docker Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch 'staging'
                }
            }
            steps {
                container('docker') {
                    script {
                        echo "🐳 Building Docker image..."
                        
                        // Build application JAR
                        container('maven') {
                            sh 'mvn clean package -DskipTests -B'
                        }
                        
                        // Build Docker image
                        def image = docker.build("${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${IMAGE_TAG}")
                        
                        // Push to registry
                        docker.withRegistry("https://${DOCKER_REGISTRY}", 'docker-registry-credentials') {
                            image.push()
                            image.push('latest')
                        }
                        
                        echo "✅ Docker image pushed: ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }
        
        stage('🔒 Image Security Scan') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch 'staging'
                }
            }
            steps {
                container('trivy') {
                    sh '''
                        echo "🔍 Scanning Docker image for vulnerabilities..."
                        trivy image --exit-code 0 --severity LOW,MEDIUM --format table ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${IMAGE_TAG}
                        trivy image --exit-code 1 --severity HIGH,CRITICAL --format table ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}:${IMAGE_TAG}
                    '''
                }
            }
        }
        
        stage('🚀 Deploy to Development') {
            when {
                branch 'develop'
            }
            steps {
                container('kubectl') {
                    script {
                        echo "🚀 Deploying to Development environment..."
                        
                        sh '''
                            # Update image tag in deployment
                            sed -i "s|{{IMAGE_TAG}}|${IMAGE_TAG}|g" k8s/deployment.yaml
                            sed -i "s|{{NAMESPACE}}|${K8S_NAMESPACE_DEV}|g" k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/ -n ${K8S_NAMESPACE_DEV}
                            
                            # Wait for deployment to complete
                            kubectl rollout status deployment/spring-boot-api -n ${K8S_NAMESPACE_DEV} --timeout=300s
                        '''
                    }
                }
            }
        }
        
        stage('🧪 Integration Tests') {
            when {
                branch 'develop'
            }
            steps {
                container('maven') {
                    sh '''
                        echo "🧪 Running integration tests..."
                        export TEST_URL="http://spring-boot-api.${K8S_NAMESPACE_DEV}.svc.cluster.local:8080"
                        mvn test -Dtest=**/*IntegrationTest -DfailIfNoTests=false
                    '''
                }
            }
        }
        
        stage('🎯 Deploy to Staging') {
            when {
                branch 'main'
            }
            steps {
                container('kubectl') {
                    script {
                        echo "🎯 Deploying to Staging environment..."
                        
                        sh '''
                            # Update image tag in deployment
                            sed -i "s|{{IMAGE_TAG}}|${IMAGE_TAG}|g" k8s/deployment.yaml
                            sed -i "s|{{NAMESPACE}}|${K8S_NAMESPACE_STAGING}|g" k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/ -n ${K8S_NAMESPACE_STAGING}
                            
                            # Wait for deployment to complete
                            kubectl rollout status deployment/spring-boot-api -n ${K8S_NAMESPACE_STAGING} --timeout=300s
                        '''
                    }
                }
            }
        }
        
        stage('🔥 Performance Tests') {
            when {
                branch 'main'
            }
            steps {
                container('maven') {
                    sh '''
                        echo "🔥 Running performance tests..."
                        # Add your performance testing commands here
                        # Example: mvn jmeter:jmeter -DtestUrl=http://spring-boot-api.staging.svc.cluster.local:8080
                    '''
                }
            }
        }
        
        stage('✅ Production Approval') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "⏳ Waiting for production deployment approval..."
                    
                    try {
                        timeout(time: 24, unit: 'HOURS') {
                            input message: 'Deploy to Production?', 
                                  ok: 'Deploy',
                                  submitterParameter: 'APPROVER'
                        }
                        echo "✅ Production deployment approved by: ${env.APPROVER}"
                    } catch (err) {
                        echo "❌ Production deployment cancelled or timed out"
                        currentBuild.result = 'ABORTED'
                        throw err
                    }
                }
            }
        }
        
        stage('🚀 Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                container('kubectl') {
                    script {
                        echo "🚀 Deploying to Production environment..."
                        
                        sh '''
                            # Update image tag in deployment
                            sed -i "s|{{IMAGE_TAG}}|${IMAGE_TAG}|g" k8s/deployment.yaml
                            sed -i "s|{{NAMESPACE}}|${K8S_NAMESPACE_PROD}|g" k8s/deployment.yaml
                            
                            # Apply Kubernetes manifests
                            kubectl apply -f k8s/ -n ${K8S_NAMESPACE_PROD}
                            
                            # Wait for deployment to complete
                            kubectl rollout status deployment/spring-boot-api -n ${K8S_NAMESPACE_PROD} --timeout=600s
                        '''
                    }
                }
            }
        }
        
        stage('🔍 Post-Deployment Verification') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                }
            }
            steps {
                script {
                    def namespace = (env.BRANCH_NAME == 'main') ? env.K8S_NAMESPACE_PROD : env.K8S_NAMESPACE_DEV
                    
                    container('kubectl') {
                        sh """
                            echo "🔍 Verifying deployment in ${namespace}..."
                            
                            # Check if pods are running
                            kubectl get pods -n ${namespace} -l app=spring-boot-api
                            
                            # Health check
                            kubectl exec -n ${namespace} deployment/spring-boot-api -- curl -f http://localhost:8080/api/users/health || exit 1
                            
                            echo "✅ Deployment verification successful!"
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
        
        success {
            script {
                if (env.BRANCH_NAME in ['main', 'develop']) {
                    slackSend(
                        channel: env.SLACK_CHANNEL,
                        color: 'good',
                        message: "✅ *SUCCESS* - ${env.JOB_NAME} #${env.BUILD_NUMBER} completed successfully!\n" +
                                "Branch: ${env.BRANCH_NAME}\n" +
                                "Commit: ${env.GIT_COMMIT.take(7)}\n" +
                                "Duration: ${currentBuild.durationString}"
                    )
                }
            }
        }
        
        failure {
            slackSend(
                channel: env.SLACK_CHANNEL,
                color: 'danger',
                message: "❌ *FAILURE* - ${env.JOB_NAME} #${env.BUILD_NUMBER} failed!\n" +
                        "Branch: ${env.BRANCH_NAME}\n" +
                        "Commit: ${env.GIT_COMMIT.take(7)}\n" +
                        "Stage: ${env.STAGE_NAME}\n" +
                        "Duration: ${currentBuild.durationString}"
            )
        }
        
        unstable {
            slackSend(
                channel: env.SLACK_CHANNEL,
                color: 'warning',
                message: "⚠️ *UNSTABLE* - ${env.JOB_NAME} #${env.BUILD_NUMBER} completed with issues!\n" +
                        "Branch: ${env.BRANCH_NAME}\n" +
                        "Commit: ${env.GIT_COMMIT.take(7)}\n" +
                        "Duration: ${currentBuild.durationString}"
            )
        }
    }
} 
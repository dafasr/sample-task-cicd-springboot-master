# Spring Boot Technical Assessment API

A comprehensive Spring Boot REST API with Docker containerization and Kubernetes deployment, demonstrating DevOps best practices and CI/CD implementation.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [API Endpoints](#api-endpoints)
- [Docker Usage](#docker-usage)
- [Kubernetes Deployment](#kubernetes-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Monitoring and Observability](#monitoring-and-observability)
- [Development](#development)
- [Testing](#testing)

## 🚀 Project Overview

This project demonstrates a production-ready Spring Boot application with:

- **RESTful API** for user management
- **Docker containerization** with multi-stage builds
- **Kubernetes deployment** with comprehensive manifests
- **CI/CD pipeline** using Jenkins
- **Monitoring and observability** integration
- **Security best practices** implementation

## 🛠 Technology Stack

### Backend
- **Java 17** - Programming language
- **Spring Boot 3.2.0** - Application framework
- **Spring Data JPA** - Data persistence
- **H2 Database** - In-memory database
- **Spring Boot Actuator** - Application monitoring
- **Swagger/OpenAPI** - API documentation

### DevOps & Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Jenkins** - CI/CD pipeline
- **Maven** - Build automation
- **SonarQube** - Code quality analysis
- **Trivy** - Security scanning

### Monitoring
- **Prometheus** - Metrics collection
- **Grafana** - Metrics visualization
- **ELK Stack** - Logging and analysis

## 📁 Project Structure

```
├── src/
│   ├── main/
│   │   ├── java/com/techassessment/
│   │   │   ├── Application.java          # Main application class
│   │   │   ├── controller/               # REST controllers
│   │   │   ├── service/                  # Business logic
│   │   │   ├── repository/               # Data access layer
│   │   │   └── model/                    # Entity models
│   │   └── resources/
│   │       └── application.yml           # Application configuration
│   └── test/                             # Test classes
├── k8s/                                  # Kubernetes manifests
│   ├── namespace.yaml                    # Namespace definitions
│   ├── deployment.yaml                   # Application deployment
│   ├── service.yaml                      # Service definitions
│   ├── ingress.yaml                      # Ingress configuration
│   ├── configmap.yaml                    # Configuration management
│   └── hpa.yaml                          # Horizontal Pod Autoscaler
├── Dockerfile                            # Docker image definition
├── Jenkinsfile                           # CI/CD pipeline
├── CICD-FLOW.md                         # CI/CD flow documentation
├── pom.xml                              # Maven configuration
└── README.md                            # Project documentation
```

## 🚀 Quick Start

### Prerequisites
- Java 17+
- Maven 3.6+
- Docker
- Kubernetes cluster (local or cloud)

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd spring-boot-technical-assessment
   ```

2. **Run the application**
   ```bash
   mvn spring-boot:run
   ```

3. **Access the application**
   - API: http://localhost:8080
   - Health Check: http://localhost:8080/api/users/health
   - Swagger UI: http://localhost:8080/swagger-ui.html
   - H2 Console: http://localhost:8080/h2-console

## 📡 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users` | Get all users |
| GET | `/api/users/{id}` | Get user by ID |
| GET | `/api/users/email/{email}` | Get user by email |
| POST | `/api/users` | Create new user |
| PUT | `/api/users/{id}` | Update user |
| DELETE | `/api/users/{id}` | Delete user |
| GET | `/api/users/health` | Health check |

### Example Request
```bash
# Create a new user
curl -X POST http://localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john.doe@example.com",
    "phone": "1234567890"
  }'
```

## 🐳 Docker Usage

### Build Image
```bash
docker build -t spring-boot-api:latest .
```

### Run Container
```bash
docker run -p 8080:8080 spring-boot-api:latest
```

### Multi-stage Build Benefits
- **Optimized image size** - Separates build and runtime environments
- **Security** - Reduces attack surface by excluding build tools
- **Caching** - Efficient layer caching for faster builds

## ☸️ Kubernetes Deployment

### Deploy to Kubernetes

1. **Create namespaces**
   ```bash
   kubectl apply -f k8s/namespace.yaml
   ```

2. **Deploy application**
   ```bash
   # For development environment
   sed 's/{{NAMESPACE}}/development/g; s/{{IMAGE_TAG}}/latest/g' k8s/deployment.yaml | kubectl apply -f -
   kubectl apply -f k8s/service.yaml -n development
   kubectl apply -f k8s/ingress.yaml -n development
   kubectl apply -f k8s/configmap.yaml -n development
   kubectl apply -f k8s/hpa.yaml -n development
   ```

3. **Verify deployment**
   ```bash
   kubectl get pods -n development
   kubectl get services -n development
   ```

### Key Kubernetes Features

- **High Availability** - Multi-replica deployment with pod anti-affinity
- **Auto-scaling** - HPA based on CPU, memory, and custom metrics
- **Security** - Pod security context, network policies, RBAC
- **Monitoring** - Prometheus integration and health checks
- **Configuration** - ConfigMaps and Secrets management

## 🔄 CI/CD Pipeline

The Jenkins pipeline includes:

### Pipeline Stages
1. **Preparation** - Workspace setup and code checkout
2. **Code Quality & Security Analysis** - Parallel execution of:
   - Maven build and test
   - SonarQube analysis
   - OWASP dependency check
3. **Quality Gate** - SonarQube quality gate validation
4. **Docker Build** - Multi-stage image build and push
5. **Image Security Scan** - Trivy vulnerability scanning
6. **Environment Deployments**:
   - Development (automatic on develop branch)
   - Staging (automatic on main branch)
   - Production (manual approval required)
7. **Post-deployment Verification** - Health checks and smoke tests

### Pipeline Features
- **Branch-based deployment** strategy
- **Parallel execution** for faster builds
- **Security scanning** at multiple levels
- **Manual approval** for production deployments
- **Slack notifications** for build status
- **Comprehensive monitoring** and alerting

## 📊 Monitoring and Observability

### Health Checks
- **Liveness Probe**: `/actuator/health/liveness`
- **Readiness Probe**: `/actuator/health/readiness`
- **Startup Probe**: `/actuator/health`

### Metrics
- **Application Metrics**: Available at `/actuator/metrics`
- **Prometheus Metrics**: Available at `/actuator/prometheus`
- **Custom Metrics**: Business-specific metrics

### Logging
- **Structured Logging** with configurable levels
- **Log Aggregation** via ELK stack integration
- **Distributed Tracing** with correlation IDs

## 🔧 Development

### Build Commands
```bash
# Compile and test
mvn clean compile test

# Package application
mvn clean package

# Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=development

# Generate test coverage report
mvn jacoco:report
```

### Code Quality
```bash
# Run SonarQube analysis locally
mvn sonar:sonar

# OWASP dependency check
mvn org.owasp:dependency-check-maven:check
```

## 🧪 Testing

### Test Categories
- **Unit Tests** - Service and repository layer testing
- **Integration Tests** - End-to-end API testing
- **Security Tests** - Vulnerability assessments
- **Performance Tests** - Load and stress testing

### Running Tests
```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=UserServiceTest

# Run integration tests
mvn test -Dtest=**/*IntegrationTest
```

## 🔒 Security Features

- **Container Security** - Non-root user, read-only filesystem
- **Kubernetes Security** - Pod security policies, network policies
- **Application Security** - Input validation, CORS configuration
- **Secrets Management** - Kubernetes secrets for sensitive data
- **Security Scanning** - Automated vulnerability detection

## 🚦 Environment Configuration

| Environment | Branch | Auto-Deploy | Approval Required |
|-------------|--------|-------------|-------------------|
| Development | develop | ✅ | ❌ |
| Staging | main | ✅ | ❌ |
| Production | main | ❌ | ✅ |

## 📈 Performance Characteristics

- **Startup Time**: ~30 seconds
- **Memory Usage**: 512MB-1GB
- **CPU Usage**: 250m-500m
- **Throughput**: 1000+ requests/second
- **Auto-scaling**: 2-10 replicas based on load

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## 📄 License

This project is created for technical assessment purposes.

## 📞 Support

For questions or issues, please contact the development team or create an issue in the repository.

---

**Built with ❤️ for technical assessment** 
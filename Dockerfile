# --- Tahap 1: Build ---
# Menggunakan image Maven resmi untuk membangun artefak aplikasi (.jar)
# 'AS build' menamai tahap ini sebagai 'build'
FROM maven:3.9.6-eclipse-temurin-17-focal AS build

# Menentukan direktori kerja di dalam container
WORKDIR /app

# Menyalin file pom.xml untuk men-download dependensi terlebih dahulu
# Ini memanfaatkan cache layer Docker, sehingga dependensi tidak di-download ulang setiap kali ada perubahan kode
COPY pom.xml .
RUN mvn dependency:go-offline

# Menyalin seluruh source code proyek
COPY src ./src

# Menjalankan proses build dan packaging aplikasi menjadi file .jar
# -DskipTests digunakan untuk mempercepat proses build di Docker
RUN mvn package -DskipTests

# --- Tahap 2: Run ---
# Menggunakan image OpenJDK yang jauh lebih ringan untuk menjalankan aplikasi
FROM openjdk:17-jdk-slim

# Menentukan direktori kerja
WORKDIR /app

# Menyalin file .jar yang sudah di-build dari tahap 'build'
COPY --from=build /app/target/*.jar app.jar

# Memberi tahu Docker bahwa container akan listen pada port 8080
EXPOSE 8080

# Perintah untuk menjalankan aplikasi saat container dimulai
ENTRYPOINT ["java", "-jar", "app.jar"]
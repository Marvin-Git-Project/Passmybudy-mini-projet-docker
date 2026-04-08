# Étape 1 : Build avec Maven
# ===============================
# Maven + Java 17 pour compiler le projet
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# Pour définir le dossier de travail
WORKDIR /app

# Copie des fichiers nécessaires au build
COPY pom.xml .
COPY src ./src

# Compile le projet et génére le fichier .jar
RUN mvn clean package -DskipTests

# Étape 2 : Image finale (runtime)
# ===============================
# Image (légère) pour exécuter l'application
FROM amazoncorretto:17-alpine

# Informations (créateur + description)
LABEL maintainer="Marvin-Git-Project"
LABEL description="Backend Spring Boot - PayMyBuddy"

# Pour définir le dossier de travail
WORKDIR /app

# Copie le .jar depuis l'étape précédente
COPY --from=builder /app/target/paymybuddy.jar app.jar

# Expose le port de l'application
EXPOSE 8080

# Variables d’environnement
# (elles seront injectées via le fichier .env avec docker-compose)

# Commande de lancement
CMD ["java", "-jar", "app.jar"]

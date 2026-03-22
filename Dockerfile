# Étape 1 : L’image de base
#==============================
# On utilise Amazon Corretto 17 (énoncé + Java 17 dans "pom.xml")
FROM amazoncorretto:17-alpine

# Étape 2 : Les informations (« créateur et description »)
# ===============================
LABEL maintainer="Marvin-Git-Project"
LABEL description="Backend Spring Boot - PayMyBuddy"

# Étape 3 : Définir le dossier de travail
# ===============================
#Créer le dossier "app" | Toutes les commandes s’exécutent dedans
WORKDIR /app

# Étape 4 : Copier le fichier JAR
# ===============================
# Depuis le dossier "target", copie .jar généré par Maven ds le container -->
# (renommé app.jar)
COPY target/paymybuddy.jar app.jar

# Étape 5 : Exposer le port
# ===============================
# Spring Boot tourne sur le port 8080 par défaut
EXPOSE 8080

# Étape 6 : Variables d'environnement
# ===============================
# Pour des raisons de sécurité, pas d’info de connexion (ex : mdp)
# Elles seront injectées via un fichier .env


# Étape 7 : Commande de lancement
# ===============================
# Lance l'application Spring Boot
CMD ["java", "-jar", "app.jar"]



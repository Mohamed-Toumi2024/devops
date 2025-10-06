# 1️⃣ Utiliser une image Java 17 légère
FROM eclipse-temurin:17-jre-alpine

# 2️⃣ Créer le dossier de travail dans le container
WORKDIR /app

# 3️⃣ Copier le jar compilé depuis target/ vers le container
COPY target/student-management-0.0.1-SNAPSHOT.jar app.jar

# 4️⃣ Créer un utilisateur non-root (bonne pratique)
RUN addgroup -S app && adduser -S -G app app
USER app

# 5️⃣ Exposer le port utilisé par ton application Spring Boot
EXPOSE 8089

# 6️⃣ Option pour passer des options JVM java runtime
ENV JAVA_OPTS=""

# 7️⃣ Lancer l’application
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]

pipeline {
 environment {
   PROJECT = "devops-practice-411411"
   APP_NAME = "springboot"
   FE_SVC_NAME = "${APP_NAME}-frontend"
   CLUSTER = "spring-boot"
   CLUSTER_ZONE = "us-central1-c"
   IMAGE_TAG = "us-central1-docker.pkg.dev/devops-practice-411411/springboot/metricsapp:v1.0.${env.BUILD_NUMBER}"
   JENKINS_CRED = "google-servicecacount"
 }

 agent {
   kubernetes {
     label 'sample-app'
     defaultContainer 'jnlp'
     yaml """
apiVersion: v1
kind: Pod
metadata:
 labels:
   component: ci
spec:
 serviceAccountName: cd-jenkins
 containers:
   - name: maven
     image: maven
     command:
       - cat
     tty: true
   - name: gcloud
     image: gcr.io/cloud-builders/gcloud
     command:
       - cat
     tty: true
   - name: kubectl
     image: gcr.io/cloud-builders/kubectl
     command:
       - cat
     tty: true
"""
   }
 }

 stages {
   stage('Test') {
     steps {
       container('maven') {
         sh """
           mvn test
         """
       }
     }
   }

   stage('Build APP') {
     steps {
       container('maven') {
         sh """
           sudo apt update
           mvn clean package
         """
       }
     }
   }

   stage('Docker Image') {
     steps {
       container('gcloud') {
         script {
           withCredentials([string(credentialsId: 'google-servicecacount', variable: 'GOOGLE_CREDENTIALS_JSON')]) {
             sh "echo '$GOOGLE_CREDENTIALS_JSON' > /tmp/keyfile.json"
             sh "gcloud auth activate-service-account --key-file=/tmp/keyfile.json"
           }

           sh """
             sudo apt update
             sudo apt install maven
             mvn clean package
             docker build -t ${IMAGE_TAG} .
             gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
             docker push ${IMAGE_TAG}
           """
         }
       }
     }
   }

   stage('Deploy Production') {
     steps {
       container('kubectl') {
         sh("sed -i.bak 's#us-central1-docker.pkg.dev/devops-practice-411411/springboot/metricsapp:latest#${IMAGE_TAG}#' ./production/deployment.yaml")
         step([$class: 'KubernetesEngineBuilder', namespace: 'production', projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'production', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
       }
     }
   }

   stage('Deploy Dev') {
     steps {
       container('kubectl') {
         sh("sed -i.bak 's#us-central1-docker.pkg.dev/devops-practice-411411/springboot/metricsapp:latest#${IMAGE_TAG}#' ./staging/deployment.yaml")
         step([$class: 'KubernetesEngineBuilder', namespace: "staging", projectId: env.PROJECT, clusterName: env.CLUSTER, zone: env.CLUSTER_ZONE, manifestPattern: 'staging', credentialsId: env.JENKINS_CRED, verifyDeployments: false])
       }
     }
   }
 }
}


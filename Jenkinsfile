pipeline {
    agent any

    // Removi o bloco environment problemático que estava causando o 'null'
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                slackSend channel: '#ci-devops', message: "Checkout iniciado", tokenCredentialId: 'slack-token'
            }
        }

        stage('Build & Push Images') {
            steps {
                script {
                    // ACESSO DIRETO: Usamos as variáveis conforme elas estão no seu print
                    // O Jenkins injeta as variáveis de ambiente globais diretamente no escopo do script
                    
                    def tag      = "latest"
                    def registry = "https://${REGISTRY}" // Pega do seu print
                    
                    // Montagem das imagens usando as variáveis que você mostrou no print
                    def webImg   = "${IMAGE_WEB}:${tag}"
                    def dbImg    = "${IMAGE_DB}:${tag}"
                    def nginxImg = "${IMAGE_NGINX}:${tag}"

                    echo "Subindo para o registro: ${registry}"
                    echo "Imagem Web: ${webImg}"

                    docker.withRegistry(registry, 'dockerhub') {
                        docker.build(webImg,   "-f Dockerfileweb .").push()
                        docker.build(dbImg,    "-f Dockerfiledb .").push()
                        docker.build(nginxImg, "-f Dockerfilenginx .").push()
                    }
                }
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                script {
                    // Referenciando as variáveis diretamente para o scan
                    sh """
                        trivy image ${IMAGE_WEB}:latest --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-web.json
                        trivy image ${IMAGE_DB}:latest  --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-db.json
                        trivy image ${IMAGE_NGINX}:latest --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-nginx.json
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-*.json', fingerprint: true
                }
            }
        }

        stage('Deploy') {
            steps {
                // Aqui usamos a variável COMPOSE_FILE do seu print
                sh """
                    docker compose -f ${COMPOSE_FILE} pull
                    docker compose -f ${COMPOSE_FILE} up -d
                """
            }
        }
    }

    post {
        success {
            slackSend channel: '#ci-devops', message: "Pipeline finalizado com sucesso!", tokenCredentialId: 'slack-token'
        }
        failure {
            slackSend channel: '#ci-devops', message: "Pipeline falhou!", tokenCredentialId: 'slack-token'
        }
    }
}
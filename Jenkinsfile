pipeline {
    agent any

    environment {
        TAG          = "latest"
        // Pegamos os valores diretamente do Jenkins. 
        // Se estiverem vazios no Jenkins, o pipeline usará o que está após o ?:
        REGISTRY     = "${env.REGISTRY ?: 'registry.hub.docker.com'}"
        COMPOSE_FILE = "${env.COMPOSE_FILE ?: 'docker-compose.yml'}"
        
        // Não declaramos as imagens aqui para evitar o erro 'null' 
        // Vamos montá-las dentro dos stages para maior segurança.
    }

    stages {
        stage('Checkout') {
            steps {
                sh 'echo "Checking out repository..."'
                checkout scm
                slackSend channel: '#ci-devops', message: "Checkout iniciado", tokenCredentialId: 'slack-token'
            }
        }

        stage('Build Images') {
            steps {
                script {
                    // Montamos os nomes aqui dentro para garantir que o Jenkins preencheu as variáveis
                    def webImg   = "${env.IMAGE_WEB}:${TAG}"
                    def dbImg    = "${env.IMAGE_DB}:${TAG}"
                    def nginxImg = "${env.IMAGE_NGINX}:${TAG}"

                    slackSend channel: '#ci-devops', message: "Build iniciado para: ${webImg}", tokenCredentialId: 'slack-token'

                    docker.withRegistry("https://${REGISTRY}", 'dockerhub') {
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
                    // Referenciando as variáveis do ambiente global
                    def webImg   = "${env.IMAGE_WEB}:${TAG}"
                    def dbImg    = "${env.IMAGE_DB}:${TAG}"
                    def nginxImg = "${env.IMAGE_NGINX}:${TAG}"

                    slackSend channel: '#ci-devops', message: "Rodando Trivy Scan...", tokenCredentialId: 'slack-token'

                    sh """
                        trivy image ${webImg}   --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-web.json
                        trivy image ${dbImg}    --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-db.json
                        trivy image ${nginxImg} --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-nginx.json
                    """
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-*.json', fingerprint: true
                    slackSend channel: '#ci-devops', message: "Trivy scan concluído.", tokenCredentialId: 'slack-token'
                }
            }
        }

        stage('Test in Containers') {
            steps {
                slackSend channel: '#ci-devops', message: "Subindo containers para testes...", tokenCredentialId: 'slack-token'
                sh """
                    docker rm -f web1 web2 web3 db nginx || true
                    docker compose -f ${COMPOSE_FILE} up -d
                    sleep 5
                    curl -I http://localhost || exit 1
                    docker compose -f ${COMPOSE_FILE} down
                """
            }
        }

        stage('Deploy to Production') {
            steps {
                slackSend channel: '#ci-devops', message: "Deploy em produção iniciado...", tokenCredentialId: 'slack-token'
                sh """
                    docker compose pull
                    docker compose up -d
                """
            }
        }
    }

    post {
        success {
            slackSend channel: '#ci-devops', message: "Pipeline finalizado com sucesso! Build #${BUILD_NUMBER}", tokenCredentialId: 'slack-token'
        }
        failure {
            slackSend channel: '#ci-devops', message: "Pipeline falhou! Verifique o console. Build #${BUILD_NUMBER}", tokenCredentialId: 'slack-token'
        }
    }
}
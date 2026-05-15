pipeline {
    agent any

    environment {
        // Namespace fixo do seu Docker Hub para evitar o erro 'null'
        DOCKER_USER  = "danielprodrigues"
        TAG          = "latest"
        
        // Definição clara das imagens utilizando a variável declarada acima
        IMAGE_WEB    = "${DOCKER_USER}/web:${TAG}"
        IMAGE_DB     = "${DOCKER_USER}/db:${TAG}"
        IMAGE_NGINX  = "${DOCKER_USER}/nginx:${TAG}"
        
        // Nome padrão do arquivo docker compose
        COMPOSE_FILE = "docker-compose.yml" 
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
                slackSend channel: '#ci-devops', message: "Build das imagens iniciado", tokenCredentialId: 'slack-token'

                script {
                    // Autentica no Docker Hub usando a sua credencial salva no Jenkins
                    docker.withRegistry('', 'dockerhub') {
                        docker.build(IMAGE_WEB,   "-f Dockerfileweb .").push()
                        docker.build(IMAGE_DB,    "-f Dockerfiledb .").push()
                        docker.build(IMAGE_NGINX, "-f Dockerfilenginx .").push()
                    }
                }
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                slackSend channel: '#ci-devops', message: "Rodando Trivy Scan...", tokenCredentialId: 'slack-token'

                sh """
                    trivy image ${IMAGE_WEB}   --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-web.json
                    trivy image ${IMAGE_DB}    --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-db.json
                    trivy image ${IMAGE_NGINX} --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-nginx.json
                """
            }
            post {
                always {
                    archiveArtifacts artifacts: 'trivy-*.json', fingerprint: true
                    slackSend channel: '#ci-devops', message: "Trivy scan concluído. Relatórios disponíveis nos artefatos.", tokenCredentialId: 'slack-token'
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

                script {
                    docker.withRegistry('', 'dockerhub') {
                        sh """
                            docker compose -f ${COMPOSE_FILE} pull
                            docker compose -f ${COMPOSE_FILE} up -d
                        """
                    }
                }
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
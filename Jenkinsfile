pipeline{
    agent any 
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("sonar quality check"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                    }

                    timeout(time: 5, unit: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                           error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }

                }  
            }
        }
        stage("docker build & docker push"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'docker_pass', variable: 'docker_password')]) {
                             sh '''
                                docker build -t 34.71.22.147:8083/springapp:${VERSION} .
                                docker login -u admin -p $docker_password 34.71.22.147:8083 
                                docker push  34.71.22.147:8083/springapp:${VERSION}
                                docker rmi 34.71.22.147:8083/springapp:${VERSION}
                            '''
                    }
                }
            }
        }
        stage('indentifying misconfigs using datree in helm charts'){
            steps{
                script{

                    dir('kubernetes/') {
                        withEnv(['DATREE_TOKEN=84a999c7-8aed-4c8b-ad55-1ff39d28344e']) {
                              sh 'helm datree test myapp/'
                        }
                    }
                }
            }
        }
    }
}

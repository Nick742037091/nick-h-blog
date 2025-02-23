pipeline {
  agent {
    kubernetes {
      inheritFrom 'nodejs base'
      containerTemplate {
        name 'nodejs'
        image 'docker.1ms.run/node:18-alpine'
      }
    }
  }


  environment {
    // REGISTRY / DOCKERHUB_NAMESPACE / APP_NAME 三个全局变量会被使用，不能删除
    REGISTRY = 'harbor.nick-h.cn'
    DOCKERHUB_NAMESPACE = 'qq742037091'
    APP_NAME = 'nick-h-blog'
    DOCKER_IMAGE = "${REGISTRY}/${DOCKERHUB_NAMESPACE}/${APP_NAME}:snapshot-${BUILD_NUMBER}"
    DEPLOYMENT_NAMESPACE = 'blog-project'
    DEPLOYMENT_NAME = 'blog-deployment-v1'
    CONTAINER_NAME = 'blog-container'
  }

  stages {
    stage('Clone repository') {
      steps {
          checkout(scm)
      }
    }

    stage('Run npm install') {
      steps {
        container('nodejs') {
          sh 'npm config set registry https://registry.npmmirror.com'
          sh 'npm install --global pnpm'
          sh 'pnpm config set registry https://registry.npmmirror.com'
          sh 'pnpm install'
        }

      }
    }

    stage('Run npm build') {
      steps {
        container('nodejs') {
          sh 'pnpm build'
        }
      }
    }

    stage('Run docker build') {
      agent none
      steps {
        container('base') {
          sh 'docker build -f Dockerfile -t $DOCKER_IMAGE .'
          withCredentials([usernamePassword(credentialsId: 'harbor', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
            sh 'echo "$DOCKER_PASSWORD"|docker login $REGISTRY -u "$DOCKER_USERNAME" --password-stdin'
            sh 'docker push $DOCKER_IMAGE'
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
        steps {
            script {
                // 使用 Kubernetes 凭证
                withCredentials([kubeconfigFile(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                  container('base') {
                   sh """
                    kubectl set image deployment/${DEPLOYMENT_NAME} ${CONTAINER_NAME}=${DOCKER_IMAGE} -n ${DEPLOYMENT_NAMESPACE}
                    kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${DEPLOYMENT_NAMESPACE}
                    """
                  }
                }
            }
        }
    }
  }
}
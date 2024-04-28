### 아이브 DevOps 과제

1. Vault 실행을 위한 구성 파일
    - Dockerfile([vault-dockerfile](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - config.json([config](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))

2. Vault와 Kubernetes 연동과 권한을 위한 구성 파일
    - developer-serviceaccount.yaml([developer-serviceaccount](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - developer-clusterrole.yaml([developer-clusterrole](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - developer-clusterrolebinding.yaml([developer-clusterrolebinding](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - admin-serviceaccount.yaml([admin-serviceaccount](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - admin-clusterrole.yaml([admin-clusterrole](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - admin-clusterrolebinding.yaml([admin-clusterrolebinding](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))

3. Vault CLI 작업
    - Vault에 Kubernetes Authentication 메소드 활성화
    ```sh
    $ vault auth enable kubernetes
    ```
    - Vault Kubernetes Authentication 설정
    ```sh
    $ vault write auth/kubernetes/config \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_host="https://localhost:6443" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    ```
    - Kubernetes 서비스 계정이 Vault에 로그인하여 특정 경로에 접근할 수 있도록 Vault 정책([kubernetes-policy.hcl](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))을 부여
    ```sh
    $ vault policy write  kubernetes-policy kubernetes-policy.hcl
    ```
    - Vault에서는 Kubernetes Authentication 메소드를 설정할 때 각 서비스 계정에 대한 역할 설정
    ```sh
    $ vault write auth/kubernetes/role/developer-role \
        bound_service_account_names=developer-serviceaccount \
        bound_service_account_namespaces=default \
        policies=kubernetes-policy \
        ttl=1h
    $ vault write auth/kubernetes/role/admin-role \
        bound_service_account_names=admin-serviceaccount \
        bound_service_account_namespaces=default \
        policies=kubernetes-policy \
        ttl=1h
    ```
    - developer-role 권한으로 Vault에 로그인
    ```sh
    $ vault login -method=kubernetes role=developer-role jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    $ vault login -method=kubernetes role=admin-role jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
    ```
4. pod, pvc 생성을 위한 구성 파일
    - app1-pod.yaml([app1-pod](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - app1-pvc.yaml([app1-pvc](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - app2-pod.yaml([app2-pod](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))
    - app2-pvc.yaml([app2-pvc](https://github.com/spring-petclinic/spring-petclinic-data-jdbc))

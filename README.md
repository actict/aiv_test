### 아이브 DevOps 과제

1. Vault 실행을 위한 구성 파일
    - Dockerfile([vault-dockerfile](https://github.com/actict/aiv_test/blob/main/Dockerfile))
    - config.json([config](https://github.com/actict/aiv_test/blob/main/config.json))

2. Vault와 Kubernetes 연동과 권한을 위한 구성 파일
    - developer-serviceaccount.yaml([developer-serviceaccount](https://github.com/actict/aiv_test/blob/main/developer-serviceaccount.yaml))
    - developer-clusterrole.yaml([developer-clusterrole](https://github.com/actict/aiv_test/blob/main/developer-clusterrole.yaml))
    - developer-clusterrolebinding.yaml([developer-clusterrolebinding](https://github.com/actict/aiv_test/blob/main/developer-clusterrolebinding.yaml))
    - admin-serviceaccount.yaml([admin-serviceaccount](https://github.com/actict/aiv_test/blob/main/admin-serviceaccount.yaml))
    - admin-clusterrole.yaml([admin-clusterrole](https://github.com/actict/aiv_test/blob/main/admin-clusterrole.yaml))
    - admin-clusterrolebinding.yaml([admin-clusterrolebinding](https://github.com/actict/aiv_test/blob/main/admin-clusterrolebinding.yaml))

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
    - app-service.yaml([app-service](https://github.com/actict/aiv_test/blob/main/app-service.yaml))
    - app.yaml([app](https://github.com/actict/aiv_test/blob/main/app.yaml))
    - app-pvc.yaml([app-pvc](https://github.com/actict/aiv_test/blob/main/app-pvc.yaml))
    - app-pv.yaml([app-pv](https://github.com/actict/aiv_test/blob/main/app-pv.yaml))
    - app2-service.yaml([app2-service](https://github.com/actict/aiv_test/blob/main/app2-service.yaml))
    - app2.yaml([app2](https://github.com/actict/aiv_test/blob/main/app2.yaml))
    - app2-pvc.yaml([app2-pvc](https://github.com/actict/aiv_test/blob/main/app2-pvc.yaml))
    - app-pv.yaml([app2-pv](https://github.com/actict/aiv_test/blob/main/app2-pv.yaml))

**보완사항**
    - develop 계정이 특정 pod와 pvc에 접근되도록 설정하는 부분에 대해 developer-clusterrole.yaml([developer-clusterrole](https://github.com/actict/aiv_test/blob/main/developer-clusterrole.yaml))에 추가하였습니다.
      다만, 잦은 배포로 pod명이 변경이 될 수 있어 이렇게 사용한다면 수시로 권한 부분에도 업데이트가 필요하며 관리하기 쉽지가 않아 권장하지는 않고, 네임스페이스 단위로 관리하는 것을 권장합니다.

## GitOps инфраструктура с flux-cd, flux-tofu-controller и runner с кастомным провайдером

1. Создаем локальный кластер с помощью kind
   - Установка kind (latest):
     ```bash
     sudo curl -fsSL -o /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.32.0/kind-linux-amd64
     chmod +x /usr/local/bin/kind
     kind version
     ```
   - Создание кластера (см. `clusters/local.yaml`):
     ```bash
     kind create cluster --config clusters/local.yaml
     ```
     Контекст: `kind-gitops-test`, K8s `v1.36.1`
2. Устанавливаем flux cd через flux bootstrap
   - Установка Flux CLI (если нет):
     ```bash
     curl -s https://fluxcd.io/install.sh | sudo bash
     ```
   - Bootstrap в репозиторий:
     ```bash
     flux bootstrap git \
     --url=ssh://git@github.com/beastlex-cyber/gitops-infra \
     --branch=main \
     --private-key-file=/home/user/.ssh/id_rsa_new \
     --path=clusters/gitops-test
     ```
   - Проверка:
     ```bash
     flux get all
     ```
3. Создаем кастомный runner для flux tofu controller
   - Сборка образа (из `images/`):
     ```bash
     docker build -t tf-runner-decort:v0.16.4 images/
     ```
   - Загрузка в kind-кластер:
     ```bash
     kind load docker-image tf-runner-decort:v0.16.4 --name gitops-test
     ```
   - Проверка:
     ```bash
     docker exec -it gitops-test-control-plane crictl images | grep tf-runner
     ```
4. Через HelmRelease ставим flux tofu controller
   - vанифесты из `clusters/gitops-test/`:
     ```bash
     clusters/gitops-test/helmrepository.yaml
     clusters/gitops-test/helmrelease.yaml
     ```
   - Проверка:
     ```bash
     kubectl get pods -n flux-system
     ```
5. Создаем наши ресурсы через ресурс Terraform в кластере
   - Создаём Secret с учётными данными DECORT:
     ```bash
     kubectl create secret generic decort-cred -n flux-system \
       --from-literal=DECORT_APP_ID=<your_app_id> \
       --from-literal=DECORT_APP_SECRET=<your_app_secret>
     ```
   - Создаем Terraform-ресурс:
     ```bash
     clusters/gitops-test/terraform-vm.yaml
     ```
   - Проверка:
     ```bash
     kubectl get terraform -n flux-system
     kubectl get pods -n flux-system -l app=tf-runner
     ```
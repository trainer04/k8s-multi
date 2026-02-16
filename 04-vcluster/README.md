# Пример 4: vCluster - Virtual Kubernetes Cluster

## Описание

vCluster создаёт полноценный виртуальный Kubernetes кластер внутри namespace host кластера с полной изоляцией CRD и операторов.

## Что демонстрирует пример

- Установка vCluster CLI
- Создание vCluster для Core Banking команды
- Установка Strimzi Kafka Operator внутри vCluster
- Полная изоляция CRD от host кластера
- Различные версии Kubernetes для разных команд
- ResourceQuota на уровне vCluster

## Структура

- `vcluster-values.yaml` - конфигурация vCluster
- `kafka-cluster.yaml` - пример Kafka кластера через Strimzi
- `test-isolation.sh` - скрипт для проверки изоляции

## Требования

- Kubernetes 1.23+
- kubectl с правами cluster-admin
- 2GB+ свободной RAM для vCluster
- vCluster CLI (устанавливается автоматически)

## Запуск

```bash
./start.sh
```

## Проверка

```bash
# Подключиться к vCluster
vcluster connect core-banking -n core-banking-vcluster

# Проверить что внутри полноценный K8s
kubectl get nodes
kubectl get ns

# Установить Strimzi
kubectl create ns kafka
kubectl apply -f https://strimzi.io/install/latest -n kafka

# Проверить CRD внутри vCluster
kubectl get crd | grep kafka

# Отключиться от vCluster
vcluster disconnect

# Проверить что CRD не видны в host
kubectl get crd | grep kafka
# (пусто - изоляция работает)
```

## Остановка

```bash
./stop.sh
```

## Преимущества

- Полная изоляция CRD и операторов
- Свои версии Kubernetes
- Cluster-admin права внутри vCluster
- Идеально для CI/CD и критичных workloads

## Overhead

- Control plane: ~500MB RAM, 0.2 CPU
- API Server + etcd/SQLite + Syncer
- +2-5ms latency на операции
- Оправдан для критичных сценариев

# Пример 3: Capsule Multi-Tenancy

## Описание

Capsule предоставляет полноценный multi-tenancy с автоматическими квотами, NetworkPolicy и self-service для команд.

## Что демонстрирует пример

- Установка Capsule в кластер
- Создание Tenant для команды Digital Channels
- Автоматические ResourceQuota на уровне tenant
- NetworkPolicy изоляция между tenant'ами
- Ограничения на StorageClass и IngressClass
- Self-service создание namespace

## Структура

- `tenant-digital-channels.yaml` - Tenant с политиками
- `tenant-analytics.yaml` - второй Tenant для сравнения
- `test-pod.yaml` - тестовый под для проверки изоляции

## Требования

- Kubernetes 1.23+
- kubectl с правами cluster-admin
- Helm 3+

## Запуск

```bash
./start.sh
```

## Проверка

```bash
# Проверить Tenant
kubectl get tenants

# Проверить метки
kubectl get ns mobile-app --show-labels

# Проверить квоты тенанта по количеству namespaces
kubectl get tenant digital-channels -o jsonpath='{.spec.namespaceOptions.quota}' | xargs echo "Quota:"

# Проверить использование в тенанте
kubectl get ns -l capsule.clastix.io/tenant=digital-channels --no-headers | wc -l | xargs echo "Count:"

# Проверить квоты тенанта по ресурсам
kubectl get tenant digital-channels -o yaml | grep -A 12 "resourceQuotas:"
```

## Остановка

```bash
./stop.sh
```

## Преимущества

- Минимальный overhead (~50MB)
- Автоматические квоты и политики
- Self-service для команд
- NetworkPolicy из коробки
- Поддержка 100+ tenant'ов

## Ограничения

- CRD остаются cluster-scoped
- Операторы общие для всех tenant'ов
- Нельзя дать tenant owner права cluster-admin

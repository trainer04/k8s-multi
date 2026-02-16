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

# Проверить что namespace создаются автоматически
kubectl --as=digital-user --as-group=capsule.clastix.io create ns mobile-app

# Проверить автоматические квоты
kubectl get resourcequota -n mobile-app

# Проверить изоляцию
kubectl --as=digital-user --as-group=capsule.clastix.io get ns
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

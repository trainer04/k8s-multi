# Пример 1: Базовая изоляция с Namespace + RBAC

## Описание

Простейший способ изоляции в Kubernetes - использование namespace с RBAC и ResourceQuota.

## Что демонстрирует пример

- Создание отдельных namespace для команд
- RBAC для ограничения доступа
- ResourceQuota для лимитирования ресурсов
- LimitRange для дефолтных лимитов

## Структура

- `namespace.yaml` - создание namespace
- `rbac.yaml` - Role и RoleBinding
- `resourcequota.yaml` - квоты на ресурсы
- `limitrange.yaml` - лимиты по умолчанию

## Запуск

```bash
./start.sh
```

## Проверка

```bash
# Проверить namespace
kubectl get ns digital-team

# Проверить квоты
kubectl get resourcequota -n digital-team

# Попробовать создать под от имени пользователя
kubectl --as=dev-user --as-group=digital-team run nginx --image=nginx -n digital-team
```

## Остановка

```bash
./stop.sh
```

## Ограничения этого подхода

- CRD остаются cluster-scoped (общие для всех)
- Операторы общие - обновление одного ломает других
- RBAC нужно настраивать вручную
- NetworkPolicy нужно создавать отдельно

# Пример 2: Hierarchical Namespaces (HNC)

## Описание

HNC добавляет иерархию namespace'ов с наследованием RBAC, NetworkPolicy и других ресурсов.

## Что демонстрирует пример

- Установка HNC в кластер
- Создание родительского namespace
- Создание дочерних namespace через SubnamespaceAnchor
- Наследование RBAC и политик
- Пропагация ConfigMap и Secret

## Структура

- `install-hnc.sh` - установка HNC в кластер
- `parent-namespace.yaml` - родительский namespace
- `child-namespaces.yaml` - дочерние namespace через SubnamespaceAnchor
- `rbac.yaml` - RBAC который будет унаследован
- `network-policy.yaml` - NetworkPolicy для пропагации

## Требования

- Kubernetes 1.23+
- kubectl с правами cluster-admin

## Запуск

```bash
./start.sh
```

## Проверка

```bash
# Проверить иерархию
kubectl get subnamespaceanchor -n analytics

# Проверить наследование
kubectl get role -n analytics-prod
kubectl get role -n analytics-staging

# Проверить структуру
kubectl hns tree analytics
```

## Остановка

```bash
./stop.sh
```

## Преимущества

- Автоматическое наследование RBAC
- Упрощение управления политиками
- Организационная структура namespace'ов

## Ограничения

- CRD по-прежнему cluster-scoped
- Операторы остаются общими
- Сложность при глубокой иерархии

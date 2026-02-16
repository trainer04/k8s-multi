# Примеры Multi-Tenancy в Kubernetes

Практические примеры решений multi-tenancy из презентации "Multi-tenancy и защита в многоарендных кластерах"

## Структура примеров

### 01-namespace-basic
**Базовая изоляция с Namespace + RBAC**

Простейший подход с использованием namespace, RBAC, ResourceQuota и LimitRange.

- Overhead: минимальный
- Сложность: низкая
- Изоляция CRD: ❌
- Свои операторы: ❌

**Подходит для:** малых команд (5-10 человек), simple workloads

### 02-hnc
**Hierarchical Namespaces (HNC)**

Иерархическая структура namespace'ов с автоматическим наследованием RBAC и политик.

- Overhead: ~5MB
- Сложность: средняя
- Изоляция CRD: ❌
- Свои операторы: ❌

**Подходит для:** организационной структуры, наследования политик

### 03-capsule
**Capsule Multi-Tenancy**

Полноценный multi-tenancy с Tenant как единицей управления, автоматическими квотами и NetworkPolicy.

- Overhead: ~50MB на кластер
- Сложность: средняя
- Изоляция CRD: ❌
- Свои операторы: ❌
- Поддержка: 100+ tenant'ов

**Подходит для:** большинства команд разработки, self-service, десятки tenant'ов

### 04-vcluster
**vCluster - Virtual Kubernetes**

Полноценный виртуальный Kubernetes кластер с собственным API Server, etcd и полной изоляцией CRD.

- Overhead: ~500MB на vCluster
- Сложность: высокая
- Изоляция CRD: ✅
- Свои операторы: ✅
- Разные версии K8s: ✅

**Подходит для:** критичных workloads, compliance требования, изоляция операторов

## Быстрый старт

Каждый пример содержит:
- `README.md` - описание и инструкции
- `start.sh` - установка и настройка
- `stop.sh` - очистка ресурсов
- YAML манифесты
- Скрипты для тестирования

### Запуск примера

```bash
cd examples/03-capsule
./start.sh
# ... тестирование ...
./stop.sh
```

## Сравнение решений

| Решение | Изоляция CRD | Свои операторы | Overhead | Команд | Сложность |
|---------|--------------|----------------|----------|---------|-----------|
| Namespace | ❌ | ❌ | 0 MB | 5-10 | Низкая |
| HNC | ❌ | ❌ | ~5 MB | 10-20 | Средняя |
| Capsule | ❌ | ❌ | ~50 MB | 100+ | Средняя |
| vCluster | ✅ | ✅ | ~500 MB | 5-10 | Высокая |

## Матрица выбора

| Требование | Рекомендация |
|-----------|-------------|
| Простая изоляция команд | Namespace |
| Иерархия прав | HNC |
| Self-service для команд | Capsule |
| Свои операторы/CRD | vCluster |
| Compliance (PCI DSS, SOC 2) | vCluster |
| Разные версии K8s | vCluster |
| Экономия ресурсов | Capsule |

## Требования

- Kubernetes 1.23+
- kubectl с правами cluster-admin
- Helm 3+ (для Capsule)
- 4GB+ RAM (для vCluster примеров)

## Полезные ссылки

- [Capsule Documentation](https://projectcapsule.dev/docs/)
- [Capsule GitHub Repo](https://github.com/projectcapsule)
- [vCluster Documentation](https://www.vcluster.com/docs)
- [vCluster GitHub Repo](https://github.com/loft-sh/vcluster)
- [HNC Documentation](https://github.com/kubernetes-sigs/hierarchical-namespaces)
- [Kubernetes Multi-Tenancy SIG](https://github.com/kubernetes-sigs/multi-tenancy)

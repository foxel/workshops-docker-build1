# Workshop #2 "Isolating application"

## step 0: Environment variables as a config

### Идея
При запуске docker образа пользователь может задать переменные окружения для процессов внутри контейнера:
```bash
docker run --rm -e ADMIN_PASSWORD='T3VjaFRoaXNJc1ByaXZhdGU=' hacher/secure_service
```

Данную возможность можно использовать для установки каких-либо настроек докеризированного приложения.
Данный подход применяется очень часто, даже в официальных образах популярных приложений. 
Примеры: [MySQL](https://hub.docker.com/_/mysql/), [Postgres](https://hub.docker.com/_/postgres/), [Redmine](https://hub.docker.com/_/redmine/). 

### Как сделать?

Чтобы добавить возможность конфигурирования приложения через переменные окружения не обязательно переделывать приложение.
Достаточно добавить стартовый скрипт, который подготовит/изменит конфигурационные файлы прилодения согласно переданных в 
переменных окружения параметрам. Для этого можно использовать различные инструменты. 
Самый простой (или скорее самый легковесный) вариант - использование [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html) 
 или [sed](https://www.gnu.org/software/sed/manual/sed.html).

Также можно использовать более продвинутые инструменты:
- шаблонизаторы, такие как mustache, go template, etc.
- специализированные утилиты типа `crudini`

Примеры можно посмотреть в папке `step0`

### Задание

* В `step0` есть примеры образов с изменением настроек через переменные окружения.
Для каждого из вариантов добавить возможность изменить пароль пользователя в секции AUTH.
* Какой из вариантов более надежен?

## step 1: ARG for custom builds

[ARG](https://docs.docker.com/engine/reference/builder/#arg) в Dockerfile аналогичен ENV, но используется не при запуске контейнера а при его сборке.
Соответственно его значение задается также при сборке. Делается это при помощи аргумента `--build-arg <varname>=<value>`.
Область применения данной функции может включать множество вариантов. 
Очевидное использование - задание версии приложения (или тега в репозитории) для сборки. 

### Пример

Пример можно посмотреть в папке `step1`.

### Задание

Собрать образ из примера для какой-либо версии консула. См [доступные версии consul](https://releases.hashicorp.com/consul).


## step #2: `docker build` useful arguments

`docker build` - основная команда для сборки образов для Docker. Синтаксис команды [следующий](https://docs.docker.com/engine/reference/commandline/build/):
```
docker build [OPTIONS] PATH | URL | -
```

Здесь стоит рассмотреть два вопроса: что можно отдать в качестве PATH/URL, какие полезные опции межно передать в OPTIONS.

### PATH/URL/-

Мы уже знаем что в качетве `PATH` передается контекст для сборки контейнера. Обычно мы указываем там путь к папке, который в большинстве случаев выглядит как `.`.
Но есть также варинты с использованием ссылки или stdin (`-`).

Указание stdin (`-`) в качетстве контекста дает возможность использовать tar или tar.gz архив с файлами.
В этом случае содержимое архива будет использоваться в качестве контекста.
Это полезно напрмер для сборки локаьно вытянутого репозитория для гарантии использования "чистого" содержимого репозитория.
Пример с использованием `git archive`:

```bash
git archive HEAD | docker build -
```
 
Указание ссылки позволяет использовать в качестве контекста лежащий на удаленном хосте архив (подобно предыдущему варианту) или, что более полезно, удаленный git-репозиторий.
Подробнее стоит почитать в [документации](https://docs.docker.com/engine/reference/commandline/build/#git-repositories), а ниже привожу пример:
```bash
docker build -t foxel/seafile-docker https://github.com/foxel/seafile-docker.git#6.0.9
```

### OPTIONS

Весь набор доступных агрументов для docker-build рассматривать не будем. Остановимся на наиболее полезных:

* `--tag/-t TAG` -- задание тега для собранного образа. Очень полезный аргумент, запускать сборку без которого почти бесполезно.
Собранный образ будет доступен по указанному тегу.
* `--file/-f FILE` -- указание пути к докер-файлу () в контексте. Без указания будет использован `Dockerfile` в корне контекста. 
Полезно если из одного контекста нужно иметь возможность собирать разные образы, например один для обычного использоыания, другой для девелоперского окружения.
Обычно кастомные докер-файлы имеют расширение `dockerfile`, например (`dev.dockerfile`). 
* `--pull` -- заставляет docker всегда вытягивать образ, указанный в FROM, независимо от того, есть ли он на текущей машине. 
Агрумент полезен в автоматических сборках, чтобы гарантировать использование самого свежего базового образа.
* `--add-host HOST:IP` -- делает IP видимым под именем HOST в процессе сборки.
Очень полезен если процесс сборки вытягивает какие-то артефакты/бинарники с внутренных серверов, адреса которых вбивать в Dockerfile нецелесообразно.


### Задание 

Собрать образ для `step2`, пометив его тегом `docker1/step2`. Показать вывод `docker run --rm docker1/step2`.

### Задание 2

Привести команду для сборки `step2` напрямую из репозитория данного воркшопа (`foxel/workshops-docker-build1`).

## step #3: концепция `ONBUILD`

В docker есть интересная директива `ONBUILD`. Она позволяет указать в Dockerfile директивы, которые будут выполняться при сборке образа, отнаследованного от текущего.
Синтаксис:
```
ONBUILD [INSTRUCTION]
```

Данная директива может встречасться в Dockerfile более обного раза. `INSTRUCTION` может быть любой инструкцией кроме `FROM`, `MAINTAINER` и, собственно, `ONBUILD` :).
Указанные в ONBUILD инструкции не выполняются при сборке текущего образа, но записываются в его манифест для выполнения при сборке дочерних образов.
Эти интсрукции выполняются как часть иснтрукции FROM дочернего образа.

Документация докера указывает на предполагаемое использование данной концепции для упрощения/абстрагирования процесса досборки образов приложений, например копирования настроек/кустомизаций приложения внуть образа по пути, который известен базовому образу.
Данную концепцию можно применять, например, для сборки клиентских web-приложений на базе общего образа с web-сервером, преднастроенным отдавать статику.

Интересное применение, пришедшее мне в голову, - предотвращение сборки дочерних образов при помощи заведомо падающей инструкции в ONBUILD (см. папку `step3`).

### Пример (из документации)
```
[...]
ONBUILD ADD . /app/src
ONBUILD RUN /usr/local/bin/python-build --dir /app/src
[...]
``` 

## step #4: `STOPSIGNAL` и `HEALTHCHECK`

Данные команды довольно специфичны, но могут быть довольно полезны в разных ситуациях.

`STOPSIGNAL` объявляет код сигнала, который докер будет посылать корневому процессу контейнера при его остановке.
Можно например указать 9 (SIGKILL). Может быть полезно для каких-то программ.

`HEALTHCHECK` - довольно свежая директива. Позволяет определять более сложные показатели работоспособности контейнера чем просто работа корневого процесса.
Директива имеет следующий синтаксис:
```
HEALTHCHECK [OPTIONS] CMD command
```

* `command` - любая команда, код завршения выполнения которой будет использован для оценки работоспособности контейнера: 0 - проверка успешна, 1 - проверка провалилась.
Остальные коды докер не понимает и использовать не рекомендует.
* `OPTIONS` - параметры проверки:
    * `--interval=DURATION (default: 30s)` - интервал запуска проверок;
    * `--timeout=DURATION (default: 30s)` - ограничение по времени для одной проверки;
    * `--start-period=DURATION (default: 0s)` - период времени, отсчитываемый от момента старта контейнера, в течение которого проверки не запускаются. Например, ожидаемое время запуска сервиса;
    * `--retries=N (default: 3)` - количество попыток, после которого контейнер помечается сбойным.

Стоит отметить, что сам докер не предпринимает по поводу сбоев таких проверок никаких действий.
Результат проверки доступен в метаданных контейнера и может быть использован сторонними службами для принятия какого-либо решения.

## step #5: multistage builds

Концепция многошаговых сборок (multistage builds) - один из вариантов уменьшения объема итогового образа для приложений, собираемых из исходных кодов.

Идея заключается в том, чтобы перенсти процесс компиляции (требующий большего количества зависимостей) в отдельный контейнер.
Можно конечно собирать приложение вне контейнера, а потом включать собранное приложение в конйтейнер. Но такой подход "игнорирует" множетсов преимуществ примнения докера для разработки.

### multistage "на коленке"

До внедрения функции multistage builds в сам докер, разработчики использовали для организации процесса внешние утилиты, например make или просто самописные скрипты.
Общий алгоритм работы такого срипта следующий:
* берется образ с необходимыми компиляторами;
* запускается контейнер с этим образом и примонтированным/скачиваемым исходным кодом. В данном контейнере запускается сборка проекта;
* полученный результат складывается в примонтиованную папку, попадая на хост машину;
* собирается новый образ со скомпилированным приложением, использующий минимальное количество зависимостей, необходимых для запуска приложения.

См. пример в папке `step5/builder-containers`.

### docker-way

Начиная с версии 17.05 в docker доступна функция multistage build на уровне docker-engine.

Идея реализации предусматривает возможность описывать в одном Dockerfile сборку нескольких образов последовательно с возможностью использования частей предыдущих образорв при сборке последующих.
Фактически функция позволяет спользовать директиву `FROM` неограниченное количество раз.

Также во `FROM` указывается алиас шага сборки: `FROM node as builder`. 
А в директиве `COPY` теперь можно копировать файлы из предыдущих шагов: `COPY --from=builder /src/dist /opt/app`.

### Задача

Упаковываем Angular приложение: https://github.com/Ismaestro/angular4-example-app

## Бонусы (по просьбам читателей)
* Сборка базового образа: https://docs.docker.com/engine/userguide/eng-image/baseimages/


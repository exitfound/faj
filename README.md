# **Fully Automated Jenkins**

 ![](https://i.ibb.co/ryRvCB0/image.jpg)

**Fully Automated Jenkins** – проект, предназначенный для автоматического развертывания предварительно настроенного Jenkins, с помощью такого инструмента автоматизации, как Ansible. Концепт предварительно настроенного Jenkins достигается за счет таких двух утилит, как Docker (для запуска самого Jenkins с необходимыми системными параметрами) и CasC (плагин для описания конфигурации Jenkins в виде кода). Помимо этого, средствами всё того же Ansible, опционально, можно организовать ручную установку Jenkins, подготовить узел к роли Jenkins Agent, а также настроить Nginx (+ SSL), для проксирования запросов, и т.д. Ниже представлено краткое содержание:

- [Содержание:](Fully-Automated-Jenkins)
  - [Мотивация](#Мотивация)
  - [Предустановка](#Предустановка)
  - [Структура репозитория](#структура-репозитория)
  - [Ручное развертывание](#ручное-развертывание-jenkins)
  - [Автоматическое развертывание](#развертывание-jenkins-с-помощью-ansible)
  - [Миграция заданий](#миграция-jobs-между-jenkins)
  - [Послесловие](#послесловие)

## **Мотивация:**

Мотивацией послужила задача из частного случая, когда у нас есть N-ое количество окружений, где под каждое окружение выделяется отдельный экземпляр Jenkins, для последующей работы с этим самым окружением. Следовательно, такой Jenkins необходимо предварительно настроить, со всеми его заданиями, учетными данными, пользователями, глобальными настройками и т.д. С ростом числа окружений возрастает и количество экземпляров Jenkins, которые будут задействованы. Исходя из этого возникает как желание, так и потребность в том, чтобы такой Jenkins уже обладал хоть какой-то базовой конфигруацией. Именно эту задачу и пытается решить данный проект.

## **Предустановка:**

Для успешного запуска необходимо установить минимальное количество программных коммпонентов. В частности, это:

- Git, с помощью которого вами будет загружен репозиторий из Github.

- Docker (и Docker Compose), средствами которых осуществялется ручное (в представлении этого репозитория) развертывание Jenkins в системе.

- Ansible, если вы собираетесь развертывать Jenkins в автоматическом режиме на двух или более серверах с разными ОС.

- Пользователь с правами sudo на удаленных серверах, из под которого будут запускаться плейбуки.

## **Структура репозитория:**

По умолчанию, если вы попытаетесь развернуть Jenkins с помощью данного репозитория, процесс установки и запуска будет успешно завершен (исключением являются изменения в работе самого Jenkins). Однако, если вы захотите изменить вводные данные, такие, например, как плагины с их версиями или учетные данные пользователя, то в таком случае необходимо будет изменить содержимое конфигурационных файлов. Ниже представлено краткое описание того, что собой представляет каждый файл или директория в корне репозитория:

- **Dockerfile:** Файл для сборки индивидуального образа, который используется для последующего запуска Jenkins (в роли `docker-jenkins` лежит аналог для запуска с помощью Ansible).

- **jenkins-docker-compose.yaml:** Файл для непосредственного запуска Jenkins на базе образа, который был собран с помощью Dockerfile (в роли `docker-jenkins` лежит аналог для запуска с помощью Ansible).

- **plugins.txt:** Файл, содержащий список плагинов, которые будут установлены в Jenkins во время сборки. Для каждого плагина можно указать конкретную версию, поскольку нередко бывает, что обновление плагина ломает как отдельную функциональность, так и сам Jenkins целиком. Впрочем, жесткая привязка версии плагина является опциональным действием. По умолчанию она отсутствует.

- **Makefile:** Файл с быстрыми инструкциями для запуска Jenkins в ручном режиме, включая все предварительные приготовления.

- **.env:** Файл, содержащий список переменных, которые прописаны в конфигурационных файлах для плагина CasC. В общей сложности здесь отмечены самые часто изменяемые параметры в Jenkins. Например такие, как данные пользователя, общие настройки и т.д. Работает только в сочетании с ручным развертыванием Jenkins. При взаимодействии с Ansible используются файлы из `group_vars`, в которых определен тот же механизм взаимодействия. При желании можно добавить дополнительные переменные, если они используются в файлах директории `jcasc`.

- **jcasc:** Директория с непосредственно конфигурационными файлами, которые используются для описания Jenkins в виде кода. В них же, вместо жесткой привязки какого-либо значения, указана переменная, ссылающаяся на файл `.env`. Работает только в сочетании с ручным развертыванием Jenkins. При взаимодействии с Ansible используются файлы из `group_vars`, в которых определен тот же механизм взаимодействия. При желании можно добавить дополнительные блоки конфигурации, которые определены в файлах роли `docker-jenkins` и `manual-jenkins`. Подробнее про конфигурацию Jenkins с помощью JCasC можно посмотреть вот [здесь](https://github.com/jenkinsci/configuration-as-code-plugin).

- **ansible:** Директория, предназначенная для развертывания Jenkins с помощью такого инструмента автоматизации, как Ansible. Содержит в себе различные плейбуки, роли, дополнительные конфигурационные файлы для запуска, и т.д.

- **dockerfiles:** Директория с файлами Dockerfiles, на базе которых были собраны образы различных операционных систем (образы хранятся на DockerHub). На данный момент это актуальные версии Debian, Ubuntu, Centos и OpenSUSE. В будущем список планирую расширить. Данные образы используются для тестирования плейбуков Ansible, а сам процесс осуществляется с помощью такого инструмента, как Molecule. По умолчанию все тесты организованы на базе Docker. Представлены здесь исключительно в ознакомительных целях и никак не влияют непосредственно на развертывание самого Jenkins. Однако при желании вы можете запустить тесты и у себя, чтобы посмотреть на результат работы. Особенно это уместо, если вы решили внести те или иные изменения в работу одной из ролей.

Прочие файлы являются вспомогательными и не представляют особого интереса.

## **Ручное развертывание Jenkins:**

Ручное развертывание подразумевает под собой запуск Jenkins в ручном режиме, без участия Ansible в цепочке, то есть исключительно средствами одного Docker. Это на тот случай, если кто-то с Ansible незнаком, считает его использование избыточным, не видит в нём потребности и т.д. Однако при этом хочет иметь в своём распоряжении автоматизированный Jenkins. Концепция применения остается неизменной, что при наличии, что при отсутствии Ansible. После того как проект был склонирован, необходимо перейти в директорию и запустить его с помощью Docker Compose, чтобы начался процесс сборки и запуска Jenkins. Выглядеть это будет следующим образом:

```
docker-compose -f jenkins-docker-compose.yaml up -d
```

Если после запуска была получена следующая ошибка:

```
jenkins-master | touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
jenkins-master | Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
```

То в таком случае необходимо на только что созданную директорию `data` назначить права с UID 1000. Данная ошибка возникает потому, что по умолчанию контейнер работает из под пользователя jenkins с UID 1000. Из-за разницы в правах между пользователем на хосте и пользователем внутри контейнера и возникает данная ошибка. Чтобы исправить её, необходимо выполнить следующую команду:

```
sudo chown -R 1000:1000 data
```
После первоначального запуска Jenkins необходимо переименовать директорию `jcasc` в `inactive-jcasc`. Но для чего это нужно? Дело в том, что уже давным давно существует [ишью](https://github.com/jenkinsci/configuration-as-code-plugin/issues/1426) на GitHub, в котором обсуждается следующая проблема: если использовать конфигурацию JCasC для запуска Jenkins, после сам Jenkins остановить (например, с помощью того же `docker compose down`), и затем вновь запустить, прописанная конфигурация будет применена ещё раз. И будет применена в том виде, в каком она выражена в виде кода. Это значит, что если вы, например, в промежутке между запуском и остановкой внесли какие-то дополнительные изменения в WEB-панели Jenkins, то эти изменения будут утеряны. Поэтому в данном случае мы используем конфигурацию JCasC только для первоначальной инициализации. Далее в ней нет никакой необходимости. Альтернативным же вариантом является регулярное добавление тех или иных возможностей Jenkins только в виде кода, без какого-либо использования WEB, но такой подход не каждого устроит:

```
mv jcasc inactive-jcasc
```

Чтобы избваиться от лишних действий я написал простейший Makefile, у которого присутствует четыре инструкции. Так что альтернативным вариантом запуска или удаления Jenkins можно считать следующие команды:

- **`make build:`** Создает необходимые директории и сразу назначает соответствующие права на них. Далее происходит сборка образа и последующий запуск Jenkins с помощью Docker Compose. В качестве завершения директория `jcasc` переименовывается в директорию `inactive-jcasc`. Для выполнения необходимо sudo.

- **`make start:`** Запускает Jenkins в Docker Compose, если ранее он был остановлен с помощью такой команды, как stop. Не является полноценным удалением.

- **`make stop:`** Останавливает Jenkins в Docker Compose, если ранее он был запущен с помощью такой команды, как start. Не является полноценной пересборкой.

- **`make down:`** Осуществляет полное прекращение работы контейнера Jenkins. Производит дальнейшую очистку всех контейнеров и образов в системе. Возвращает имя директории `inactive-jcasc` исходное значение. В качестве завершения все данные (директория `data`) удаляются.

После того как Jenkins был успешно запущен, можно обратиться к его панели, введя в адресной строке публичный IP-адрес или домен. Вместо привычной инициализации нас сразу попросят ввести пользователя и пароль. Ниже представлены учетные данные для входа по умолчанию:

```
Login: admin
Password: Kitezh1165
```

При этом значения параметров для входа можно изменить, если перед запуском поменять содержимое следующих двух переменных в файле `.env`:

```
JCASC_JENKINS_ADMIN_USER="admin"
JCASC_JENKINS_ADMIN_PASSWORD="Kitezh1165"
```

В этот же файл, как уже было отмечено ранее, можно внести свои данные и по отношению к другим переменным, для их дальнейшего использования. Представленная учетная запись предназначена исключительно для первоначального входа. После вы можете как поменять пароль, так и подключить другой метод аутентификации.

**Примечание:** По умолчанию в файле jenkins-docker-compose.yaml указано, что Jenkins будет запущен с адресом `0.0.0.0:8080`, что означает, что он будет доступен для всего Мира. Если вы планируете использовать любой прокси, по типу Nginx, который будет обрабатывать запросы между внешним Миром и Jenkins, то в таком случае рекомендуется сменить значение с `0.0.0.0:8080` на `127.0.0.1:8080` в файле Compose. Таким образом до Jenkins никоем образом не выйдет достучаться из вне напрямую.

## **Развертывание Jenkins с помощью Ansible:**

Развертывание с помощью такого инструмента автоматизации как Ansible подразумевает под собой всё то же классическое развертывание Jenkins, только по отношению к множественному числу узлов, и в автоматическом режиме. Присутствие Ansible не отменяет того факта, что вы также можете (при желании) изменить содержимое конфигурационных файлов, переменных и т.д. Только теперь всё это вписано в структуру самого Asnible. Так, например, аналогом файла `.env` для Ansible отчасти является файл `./ansible/group_vars/all.yaml`. Файлы же, связанные с Docker, располагаются в соответствующей роли, именуемой как docker-jenkins. Не стоит забывать и о файле `./ansible/hosts/servers`, в котором необходимо указать реальные адреса своих серверов. Стоит также понимать, что полный процесс автоматизации в контексте Ansible присущ только роли, где Jenkins запускается с помощью Docker, поскольку именно ради этого всё и задумывалось. Однако, в качестве бонуса, были добавлены и другие роли, среди которых, например, роль по ручному развертыванию Jenkins (без Docker) или роль, настраивающая Jenkins Agent на узле. Итак, для запуска основного плейбука, предназначенного для развертывания заранее настроенного Jenkins, необходимо выполнить следующую команду:

```
ansible-playbook -i ./ansible/hosts/servers -u <your-user-deploy> ./ansible/docker-jenkins.yaml
```

Если вы хотите применить плейбук по отношению к конкретной группе узлов (например, только все узлы, использующие Ubuntu), то в таком случае можно добавить параметр `-l`:

```
ansible-playbook -i ./ansible/hosts/servers -l ubuntu -u <your-user-deploy> ./ansible/docker-jenkins.yaml
```

Если вы не хотите, чтобы ваши сервера игнорировали начальную задачу по предварительному обновлению системы, то в таком случае можно выполнить следующую команду:

```
ansible-playbook -i ansible/hosts/servers -l ubuntu -u <your-user-deploy> --tags untagged ./ansible/docker-jenkins.yaml
```

**Опционально:** Если вы хотите, чтобы один из серверов начал выступать в роли агента Jenkins, то в таком случае можно выполнить команду, которая представлена ниже. По умолчанию на таком сервере будет создан пользователь с именем `jenkins-agent`. Если вы хотите данное имя изменить, необходимо внести свой вариант в файл `./ansible/group_vars/all.yaml`. В данном случае речь идет о параметре `jenkins_agent_user`. Ещё необходимо указать публичную часть ключа, который будет использоваться для связи между Master и Agent. Ключ указывается в параметре `jenkins_agent_public_key`:

```
ansible-playbook -i ./ansible/hosts/servers -u <your-user-deploy> ./ansible/manual-jenkins-agent.yaml
```

**Опционально:** Если вы хотите применить плейбук, который развернет Jenkins в ручном режиме, то в таком случае необходимо выполнить следующую команду:

```
ansible-playbook -i ./ansible/hosts/servers -u <your-user-deploy> ./ansible/manual-jenkins.yaml
```

**Опционально:** Ранее уже был упомянут тот факт, что в случае с Docker по умолчанию Jenkins запускается от адреса 127.0.0.1. Это было сделано для того, чтобы до него нельзя было достучаться извне, а прослойкой между ним и внешним Миром выступал Nginx. Если вы хотите реализовать данный сценарий в полной мере, в таком случае необходимо прибегнуть к выполнению команды, расположенной ниже. Только как и в предыдущих случаях, необходимо указать доменное имя в виде переменной, с той разницей, что конкретно в этом случае значение переменной определяется в файле `./ansible/hosts/servers`. К слову, речь идет о переменной с именем `jenkins_nginx_domain`. Это сделано так потому, что нам необходимо гибко распределять имена между всеми серверами, поскольку имя должно быть уникальным для каждого сервера:

```
ansible-playbook -i ./ansible/hosts/servers -u <your-user-deploy> ./ansible/nginx-with-certbot.yaml
```

Учетные данные для входа, как и процесс их изменения точно такой же, как и в случае с классическим развертыванием Jenkins:

```
Login: admin
Password: Kitezh1165

jcasc_jenkins_admin_user="admin"
jcasc_jenkins_admin_password="Kitezh1165"
```

## **Миграция Jobs между Jenkins:**

В качестве дополнения ко всему выше перечисленному также был создан скрипт, с помощью которого можно переместить все задания (jobs) с одного Jenkins на другой. В нашем случае это идеально подходит, когда мы сначала развертываем новый Jenkins со всеми необходимыми настройками, а после импортируем в него все задания, которые использовались в старом Jenkins. Пока что скрипт осуществляет только экспорт / импорт заданий. Быть может в будущем функциональность расширится. Вывод помощи при использовании скрипта представлен ниже:
```
These are the possible options to use: 

        [ -o | --old-jenkins ]          Specify the address of the Old Jenkins from which you want to export jobs.
        [ -n | --new-jenkins ]          Specify the address of the New Jenkins where you want to import the jobs.
        [ -u | --old-jenkins-user ]     Specify a user in Old Jenkins to access jobs.
        [ -p | --old-jenkins-password ] Specify a password for user in Old Jenkins to access jobs.
        [ -U | --new-jenkins-user ]     Specify a user in New Jenkins to upload jobs.
        [ -P | --new-jenkins-password ] Specify a password for user in New Jenkins to upload jobs.
        [ -h | --help ]                 General information about all options.

Usage: ./migrate-jobs.sh [OPTIONS] [ARGS]
```

Чтобы использовать сам скрипт со всеми необходимыми параметрами, нужно выполнить следующую команду:

```
./migrate-jobs.sh -o "http://your.old.jenkins" -n "http://your.new.jenkins" -u "old-jenkins-user" -p "old-jenkins-pass" -U "new-jenkins-user" -P "new-jenkins-pass"
```

## **Послесловие:**

В будущем планируются косметические улучшения и добавление дополнительных функций по развертыванию Jenkins с помощью Ansible, развитие скрипта по миграциям и т.д. Возможно, что также появится CI и Terraform, для ещё более быстрого и прозрачного развертывания Jenkins, хотя это и не так уж и необходимо. К слову, более детальное объяснение того, что здесь происходит описано вот в этой статье – https://t.me/opengrad/90.

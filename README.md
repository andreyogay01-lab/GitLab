# Домашнее задание к занятию "`Кластеризация и балансировка нагрузки`" - `Огай Андрей`


### Инструкция по выполнению домашнего задания

   1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или  https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
   2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
   3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
      - впишите вверху название занятия и вашу фамилию и имя
      - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
      - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
      - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции  по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
   4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
   5. В личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
   6. Любые вопросы по выполнению заданий спрашивайте в разделе “Вопросы по заданию” в личном кабинете.
   
Желаем успехов в выполнении домашнего задания!
   
### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Задание 1. 

haproxy
global
log /dev/log local0
log /dev/log local1 notice
chroot /var/lib/haproxy
user haproxy
group haproxy
daemon

defaults
log global
mode tcp
timeout connect 5s
timeout client 50s
timeout server 50s

frontend stats
mode http
bind *:8888
stats enable
stats uri /

frontend fe_tcp
bind *:80
default_backend be_tcp

backend be_tcp
balance roundrobin
server s1 127.0.0.1:8001 check
server s2 127.0.0.1:8002 check

### Скриншот работы
![Результат Задания 1](задание-1.png)
---

### Задание 2.

haproxy
global
log /dev/log local0
log /dev/log local1 notice
chroot /var/lib/haproxy
user haproxy
group haproxy
daemon

defaults
log global
mode http
timeout connect 5s
timeout client 50s
timeout server 50s

frontend fe_http
bind *:80
acl is_example_local hdr(host) -i example.local
use_backend be_http if is_example_local

backend be_http
balance roundrobin
server s1 127.0.0.1:8001 weight 2 check
server s2 127.0.0.1:8002 weight 3 check
server s3 127.0.0.1:8003 weight 4 check

### Скриншот работы
![Результат Задания 2](задание-2.png)

构建镜像：docker build -t 镜像名字:版本 .

启动命令：docker run -itd  -v 数据库挂载路径:/var/lib/mysql -p 你要用的端口:8080  镜像名字:版本

跟随 docker 进程启动--restart="always"

首次使用需要手动初始化密码：

docker ps    #查看当前所有正确运行的镜像

docker exec -it container_id bash  #进入容器

mysql 随机密码去 /var/run/log/mysql.log 里找，用 tail -100f

mysql -uroot -p

use mysql;

ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456'; 

commit;

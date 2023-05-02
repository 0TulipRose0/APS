# APS

Данный репозиторий представляеет из себя итоговый резльтат моего прохождения курса АПС.

На данном курсе перед нами стояла задача релизовать собственный процессор архитектуры **RISC-V**, путём описания его работы на языке описания аппаратуры **SystemVerilog**. 

___

В данном реализованны следующие составляющие:

+ Рализованно 32-х битное АЛУ(ALU)
+ Регистровый файл и память инструкций
+ Главный дешифратор команд на жёсткой логике(Main Decoder)
+ Реализация тракта данных через всю микроархитектуру
+ Блок загрузки и читки из памяти(LSU)
+ Система прерывания(IC)

____

Итоговый вариант выглядит следующим образом:
![finalproc](https://github.com/0TulipRose0/APS/blob/main/Pics/ml6.png)
____
В директории ***Sources*** расположены все материалы, что былм мною написаны. Так как это мой самый первый проект, то там всё максимально нелогично и непонятно. 

Перевод команд из низкоуровнего уровня команд в машинный код осуществлялись при помощи **Rars**.

Стоит также отметить, что в каталоге с симуляциями их настолько много потому, что под каждую отдельную "частичку" архитектуры писалось своё собственное тестовое окружение. Всё это отлаживалось и проверялось на отладочной плате **Nexys A7-100T**.

# SuperPangHitbox
Proyecto enfocado en la busqueda del sistema de colisiones del juego Super Pang Arcade 1990

Este proyecto se ha desarollado bajo el proposito de explorar el funcionamiento interno del juego Super Pang Arcade 1990 desarollado por Mitchel Corp. Especialmente descubrir los mecanismos de los hitbox o cuadros de colision de los diferentes elementos del juego. A continuacion se dara un detalle tecnico con lenguaje natural para explicar su funcionamiento. RECUERDE: es un proyecto en progreso qu aun esta puliendo detalles.

Para explorar el funcionamiento del juego se ha usado las herramientas MAME para la depuracion y examinar el codigo fuente, tambien se uso el emulador FBA-RR v0.0.5 para la busqueda de las RAM Values del juego y el uso de script lua para una mejor exploracion y comprobacion de los valores encontrados.

Para el uso de mame se ejecuta en cmd:

```
mame spang -window -debug
```

Para ejecutar la rom de mame en modo ventana y con la depuracion activa. Es necesario contar con la ROM y el archivo de sonidos de la placa del juego ym2413.

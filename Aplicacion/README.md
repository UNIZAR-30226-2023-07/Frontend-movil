# Como ejecutar la app

Lo primero que necesitáis es el android studio. la versión que usábamos en isoft bastará.

Luego hay que instalar el sdk de flutter y dart, siguiendo los siguientes pasos:

- [Flutter](https://docs.flutter.dev/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [???????](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

Una vez instalado flutter y dart hay que añadir los plugins a android studio:

- Abre el android studio.
- Si tienes un proyecto abierto, primero ciérralo.
- A la izquierda de la pantalla inicial hay un apartado que pone plugins. Dale ahí.
- Busca el plugin de flutter, y luego el de dart e instalalos.
- Reinicia android studio (o el pc, no me acuerdo).
- Ahora abre el proyecto de la app.
- Saldrán un montón de errores. Para solucionarlos vete a Settings/Languajes & Frameworks.
- En el apartado de Flutter le tienes indicar el path al sdk, que es donde tienes la carpeta flutter que has descomprimido antes.
- Para Dart es lo mismo, pero con el sdk de dart.
- Si todavía salen problemas, será porque tienes que descargar las dependecias del proyecto. Dale a get dependencies.

Después de eso creo que no deberíais tener problemas para ejecutar la app en un emulador o en el móvil.
Si tenéis algún problema me lo decís.

Para ejecutar la app en el emulador es igual que en isoft, solo que igual tenéis que encender el emulador antes de darle a run.
Para ejecutar la app en el móvil, iros a las opciones de administrador del móvil y activad la depuración por USB y la instalación via USB.
Si android studio no os reconoce el móvil será porque no tenéis los drivers necesarios para vuestro móvil, así que buscadlos.
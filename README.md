# Léeme cuando estés...

App en Flutter con un menú de emociones. Al tocar una emoción, se abre la carta correspondiente.

## Cómo correrla

1. Descomprime el archivo.
2. Abre una terminal dentro de la carpeta `leeme_cuando_estes`.
3. Ejecuta:
   ```
   flutter pub get
   flutter run
   ```

## Estructura

- `lib/main.dart` — punto de entrada de la app.
- `lib/models/letter_model.dart` — modelo `Letter` (emoción, título, texto, color, ícono).
- `lib/data/letters_data.dart` — aquí están las 10 cartas con su texto completo. Puedes editar, agregar o quitar cartas desde este archivo.
- `lib/screens/home_screen.dart` — pantalla de inicio con el menú.
- `lib/screens/letter_screen.dart` — pantalla que muestra la carta seleccionada.

## Cómo agregar una nueva carta

Solo agrega un nuevo `Letter(...)` a la lista en `letters_data.dart`, con su `emotion`, `title`, `body`, `color` e `icon`. Aparecerá automáticamente en el menú, no hace falta tocar nada más.

## Cambiar el ícono de la app

Ya está configurado el paquete `flutter_launcher_icons` con el ícono nuevo en `assets/icon/icon.png`.

Para generarlo en Android e iOS, corre en la carpeta del proyecto:

```
flutter pub get
dart run flutter_launcher_icons
```

Después de eso, desinstala la app del emulador/celular (si ya la tenías instalada) y vuelve a darle Run, para que tome el ícono nuevo.

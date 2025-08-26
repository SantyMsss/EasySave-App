### 📌 Flujo de Ramas

1. **`main`**:

   * Rama principal y **siempre estable**
   * Contiene solo código probado y listo para producción
   * **Protegida**: requiere review y tests passing para merge

2. **`develop`**:

   * Rama de integración y **desarrollo activo**
   * Aquí se mergean las ramas de características antes de pasar a `main`
   * Puede contener código en preparación para la siguiente release

3. **Ramas de características**:

   * Nomenclatura: `feature/nombre-breve-descripción` (ej: `feature/add-charts`)
   * Se crean desde `develop`
   * Se mergean a `develop` mediante **Pull Request (PR)** tras revisión

---

### ✅ Proceso para Contribuir

1. Crear una rama desde `develop`:

   ```bash
   git checkout develop
   git checkout -b feature/nueva-funcionalidad
   ```

2. Commitear cambios con mensajes claros:

   ```bash
   git commit -m "feat: add savings progress chart"
   ```

3. Abrir un **Pull Request** en GitHub hacia `develop`:

   * Asignar al menos **1 revisor**
   * Describir los cambios y relacionar el issue
   * Esperar aprobación y que pasen los tests

4. Mergear solo tras:

   * ✅ **Review aprobado** por al menos 1 dev
   * ✅ **Tests automatizados** pasando
   * ✅ **Conflicts resueltos**

---

### 🛡️ Protecciones de Rama

* `main` está protegida:

  * Requiere pull request antes de merge
  * Requiere status checks (Flutter test, format)
  * Requiere review de al menos 1 persona

---

### 🏷️ Etiquetas Útiles en PRs

* `feat`: Nueva funcionalidad
* `fix`: Corrección de bugs
* `docs`: Cambios en documentación
* `refactor`: Mejoras de código sin cambiar funcionalidad

---

## 🚀 Instalación

```bash
flutter pub get
flutter run
```

## 📞 Contacto

¿Preguntas? Abre un issue o contacta al equipo de desarrollo.
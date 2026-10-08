# Changelog

## v1.3

### Lorica — OpenGL moderno

- Soporte GL 3.1 → 4.3 sobre OpenGL ES 3.1/3.2: compute, SSBO,
  tessellation, program pipelines, texture views, multi-bind, indirect
  draws, transform feedback objects.
- `ARB_direct_state_access` (GL 4.5): ~90 funciones DSA cuando la app
  anuncia 3.3 o superior.
- Contextos core por `glXCreateContextAttribsARB`: la app pide la
  version que quiere (hasta 4.3) y la obtiene. Los legacy siguen en 2.1.
- Verificado sobre Mali-G52 MC2: barrido 3.1 → 4.3, mas ciclo
  core/legacy/core, todo OK.

### Scutum v1.3 — rendimiento

- Shared memory en vez de socket Unix. Luanti: 30 → 40 fps promedio,
  picos de 60.

### SuperTuxKart

- Vuelve al camino GLX → Lorica. `LIBGL_GL=33` en el prefix.

### Licenciamiento

- Todo el proyecto relicenciado a GPL-3.0.
- Orator archivado (deprecado, reemplazado por lectura directa de PCM
  en Java).

### Documentacion

- READMEs reescritos en ingles en todos los repos.

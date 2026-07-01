# 🏥 Medical Cost Analysis — EDA & Modelo Predictivo

<div align="center">

![R](https://img.shields.io/badge/R-4.3+-276DC3?style=for-the-badge&logo=r&logoColor=white)
![ggplot2](https://img.shields.io/badge/ggplot2-3.4+-FF6B6B?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-2E8B57?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-F5A623?style=for-the-badge)
![Domain](https://img.shields.io/badge/Domain-Health%20Data-1E2761?style=for-the-badge)

**Análisis exploratorio y modelado predictivo de costos médicos en la región southeast de EE.UU.**

*¿Qué hace que algunas personas generen costos médicos 4 veces mayores que otras? Este proyecto lo responde con datos.*

<!-- IMAGEN SUGERIDA: images/cover_banner.png — banner con el gráfico de scatter coloreado por fumador -->

</div>

---

## 📌 Descripción

Este proyecto analiza un dataset de **1.338 asegurados médicos** en Estados Unidos con el objetivo de identificar qué variables explican mejor los costos médicos individuales. El análisis se enfoca en la **región southeast (364 registros)** y combina exploración de datos, análisis de correlación y construcción progresiva de modelos de regresión lineal.

El hallazgo central: el **tabaquismo** es el predictor dominante, y su efecto se **amplifica significativamente en presencia de obesidad**, una interacción que ninguno de los dos factores revela por separado.

---

## 🎯 Objetivo

Determinar cuáles son los factores demográficos y de estilo de vida que mejor predicen los costos médicos de los asegurados, con foco en la región southeast, y construir un modelo de regresión lineal que explique la mayor varianza posible con variables interpretables.

---

## ✨ Características del análisis

- ✅ Validación de calidad de datos (nulos, duplicados, outliers)
- ✅ Análisis exploratorio completo con visualizaciones en ggplot2
- ✅ Matriz de correlación con todas las variables
- ✅ Construcción progresiva de 4 modelos de regresión lineal
- ✅ Identificación y análisis de interacciones entre variables
- ✅ Validación de resultados en las 4 regiones del dataset
- ✅ Reporte en R Markdown con resultados reproducibles

---

## 🛠️ Tecnologías

| Herramienta | Uso |
|---|---|
| `R 4.3+` | Lenguaje principal |
| `ggplot2` | Visualizaciones |
| `dplyr` | Manipulación de datos |
| `corrplot` | Matriz de correlación |
| `ggpubr` | Composición de gráficos |
| `R Markdown` | Reporte final |

---

## 📁 Estructura del proyecto

```
medical-cost-eda/
│
├── data/
│   └── insurance.csv            # Dataset original
│
├── images/
│   ├── cover_banner.png         # Banner del README
│   ├── dist_costos.png          # Distribución de costos
│   ├── boxplot_fumador.png      # Boxplot por condición de fumador
│   ├── correlaciones.png        # Gráfico de correlaciones
│   ├── scatter_interaccion.png  # Scatter IMC vs costos por grupo
│   └── r2_modelos.png           # Comparación R² de modelos
│
├── scripts/
│   └── analisis_EDA.R           # Script principal de análisis
│
├── report/
│   └── EDA_Southeast.Rmd        # R Markdown con reporte completo
│
└── README.md
```

---

## ⚙️ Instalación y requisitos

### Requisitos previos

- R 4.3 o superior → [descargar](https://cran.r-project.org/)
- RStudio (recomendado) → [descargar](https://posit.co/download/rstudio-desktop/)

### Instalar dependencias

```r
install.packages(c(
  "tidyverse",
  "ggplot2",
  "dplyr",
  "corrplot",
  "ggpubr"
))
```

---

## ▶️ Cómo ejecutar el proyecto

**1. Clonar el repositorio**

```bash
git clone https://github.com/EmiiFernandez/medical-cost-eda.git
cd medical-cost-eda
```

**2. Abrir el script principal en RStudio**

```
scripts/analisis_EDA.R
```

**3. Ejecutar el análisis completo**

```r
source("scripts/analisis_EDA.R")
```

**4. Generar el reporte (opcional)**

```r
rmarkdown::render("report/EDA_Southeast.Rmd")
```

---

## 📊 Resultados clave

<!-- IMAGEN SUGERIDA: images/boxplot_fumador.png aquí -->

### Brecha de costos por tabaquismo

Los fumadores generan costos médicos promedio **4.3 veces mayores** que los no fumadores:

| Grupo | Costo promedio | Costo mediano |
|---|---|---|
| No fumadores | $8.032 | $7.345 |
| Fumadores | $34.845 | $34.456 |

<!-- IMAGEN SUGERIDA: images/correlaciones.png aquí -->

### Correlaciones con costos médicos

| Variable | Correlación (r) | Interpretación |
|---|---|---|
| Fumador | **0.83** | Muy fuerte |
| Edad | 0.30 | Moderada |
| IMC | 0.20 | Débil (aislado) |
| Hijos | 0.07 | Sin efecto relevante |
| Sexo | 0.06 | Sin efecto relevante |

<!-- IMAGEN SUGERIDA: images/r2_modelos.png aquí -->

### Evolución del poder explicativo (R²)

| Modelo | Variables | R² |
|---|---|---|
| Modelo 1 | Solo IMC | 0.02 |
| Modelo 2 | Solo fumador | 0.69 |
| Modelo 3 | Fumador × IMC (interacción) | 0.80 |
| **Modelo 4** | **Fumador × IMC + Edad** | **0.88** |

---

## 🔍 Insight principal: la interacción fumador × IMC

<!-- IMAGEN SUGERIDA: images/scatter_interaccion.png aquí — es el gráfico más importante -->

El IMC **no actúa como predictor independiente**. Su efecto es condicional al tabaquismo:

- En **no fumadores**: subir el IMC apenas modifica los costos (pendiente casi plana).
- En **fumadores**: cada punto adicional de IMC suma **~$1.284** en costos médicos.

> El IMC es un amplificador del tabaquismo, no un factor de riesgo autónomo.

Este patrón se **replicó en las 4 regiones** del dataset, lo que le otorga validez externa a las conclusiones.

---

## 👤 Perfil de mayor riesgo identificado

Un asegurado de la región southeast presenta costos extremos cuando combina:

1. 🚬 **Fumador/a** — factor dominante
2. ⚖️ **IMC > 30** (obesidad) — amplificador del tabaquismo
3. 📅 **Edad > 39 años** — efecto aditivo sobre los costos

---

## 🔮 Posibles mejoras y trabajo futuro

- [ ] Implementar modelos no lineales (Random Forest, XGBoost) para comparar con regresión lineal
- [ ] Análisis por segmentos de edad (jóvenes / adultos / mayores)
- [ ] Dashboard interactivo con Shiny para explorar los datos
- [ ] Incorporar datos de todas las regiones en un modelo unificado con efectos fijos por región
- [ ] Análisis de residuos más detallado para verificar supuestos del modelo lineal

---

## 🤝 Contribución

Las contribuciones son bienvenidas. Para proponer cambios:

1. Hacé un fork del repositorio
2. Creá una branch: `git checkout -b feature/nueva-funcionalidad`
3. Commiteá tus cambios: `git commit -m 'Agrego análisis de X'`
4. Pusheá la branch: `git push origin feature/nueva-funcionalidad`
5. Abrí un Pull Request

---

## 📄 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE` para más información.

---

## 👩‍💻 Autora

**Olga**
Estudiante de Licenciatura en Ciencia de Datos · CAECE
Técnica Óptica · Coordinadora Quirúrgica · Instituto de Ojos Nano

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Conectar-0077B5?style=flat&logo=linkedin)](https://linkedin.com/in/tu-usuario)
[![GitHub](https://img.shields.io/badge/GitHub-Perfil-181717?style=flat&logo=github)](https://github.com/tu-usuario)

---

<div align="center">

*Proyecto desarrollado como trabajo final de Laboratorio de Datos I · CAECE 2025*

</div>

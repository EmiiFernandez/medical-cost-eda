########################## CONFIGURACIONES ################################

# Apagar notación científica global en R
options(scipen = 999)

# Instalación de librerías (ejecutar solo una vez)
# install.packages("ggplot2")
# install.packages("corrplot")

# Cargar librerías
library(ggplot2)
library(corrplot)

########################## FIN CONFIGURACIONES ################################

########################## CARGA Y EXPLORACIÓN INICIAL ################################

# Carga df
df <- read.csv("insurance.csv")
df_copy <- df # 1338 filas

# Exploración inicial
head(df_copy) 
summary(df_copy) 
str(df_copy)

# Frencuencia por region
table(df_copy$region)

# Filtro la población a analizar por región: southeast (364 filas)
df_se <- subset(df_copy, region == "southeast")
head(df_se)
View(df_se)

# Verificación de calidad de los datos
sum(duplicated(df_se))      # filas duplicadas -> 0
sum(is.na(df_se))            # valores NA -> 0
sum(df_se == "", na.rm = TRUE) # strings vacíos -> 0

# Exploración post filtrado por región
head(df_se) 
summary(df_se) 
str(df_se)
########################## FIN CARGA Y EXPLORACIÓN INICIAL ################################

########################## ANÁLISIS UNIVARIADO ################################ 

# Función para crear una tabla con análisis univariado para variables numericas
tabla_descriptiva <- function(df){
  
  # Seleccionar variables numéricas
  df_num <- df[, sapply(df, is.numeric)]
  
  # Función para calcular la moda
  moda <- function(x){
    ux <- unique(x)
    ux[which.max(tabulate(match(x, ux)))]
  }
  
  resultado <- data.frame()
  
  for(var in names(df_num)){
    x <- na.omit(df_num[[var]])
    fila <- data.frame(
      Variable = var,
      Moda = moda(x),
      Media = mean(x),
      Mediana = median(x),
      Desv_Estandar = sd(x),
      Coef_Variacion = round(sd(x) / mean(x) * 100, 2),
      Minimo = min(x),
      Q1 = quantile(x, 0.25),
      Q3 = quantile(x, 0.75),
      Maximo = max(x),
      RIQ = IQR(x),
      Lim_Inferior = quantile(x, 0.25) - (1.5 * IQR(x)),
      Lim_Superior = quantile(x, 0.75) + (1.5 * IQR(x)),
      P10 = quantile(x, 0.10),
      P90 = quantile(x, 0.90)
    )
    
    resultado <- rbind(resultado, fila)
  }
  
  rownames(resultado) <- NULL
  
  return(resultado)
}

tabla <- tabla_descriptiva(df_se) # Función calculando con el df 
#print(tabla)
View(tabla) # Resultados de la tabla 

# Evaluando outliers de charges
lim_sup <- tabla$Lim_Superior[tabla$Variable == "charges"]
outliers <- df_se[df_se$charges > lim_sup, ]

nrow(outliers)                              # cantidad de outliers - 26
round(nrow(outliers) / nrow(df_se) * 100, 2) # porcentaje que representan - 7.14%

# Boxplot variables cuantitativas
boxplot(df_se$age,
        main = "Boxplot de Age",
        ylab = "Edad")

boxplot(df_se$bmi,
        main = "Boxplot de BMI",
        ylab = "IMC")

boxplot(df_se$charges,
        main = "Boxplot de Charges",
        ylab = "Costos médicos")

barplot(table(df_se$children),
        main = "Frecuencia de Children",
        xlab = "Cantidad de hijos",
        ylab = "Frecuencia")

# Distribución por sexo
tabla_sex <- table(df_se$sex)
print(tabla_sex) # female: 175    male: 189
prop_sex <- prop.table(tabla_sex) * 100
round(prop_sex, 2) # Female: 48.08  Male: 51.92

barplot(tabla_sex,
        main = "Distribución por sexo",
        ylab = "Frecuencia")

# Fumadores vs NO fumadores
tabla_smoker <- table(df_se$smoker)
print(tabla_smoker)
prop_smoker <- prop.table(tabla_smoker) * 100
round(prop_smoker, 2) # no: 75 yes: 25

barplot(tabla_smoker,
        main = "Fumadores vs no fumadores",
        ylab = "Frecuencia")

# Categorias de IMC (BMI)
df_se$bmi_rango <- cut(df_se$bmi,
                       breaks = c(-Inf, 18.5, 25, 30, 40, Inf),
                       right = FALSE,
                       labels = c("Bajo peso\n(<18.5)",
                                  "Normal\n(18.5-25)",
                                  "Sobrepeso\n(25-30)",
                                  "Obesidad\n(30-40)",
                                  "Obesidad\nsevera (40+)"))

tabla_bmi <- table(df_se$bmi_rango) 
tabla_bmi # Frencuencia por categoria
round(prop.table(tabla_bmi) * 100, 2) # % por categoria

barplot(tabla_bmi,
        main = "Distribución de IMC por categoria",
        ylab = "Frecuencia",
        las = 2,
        cex.names = 0.8)

# Histogramas de distribución
hist(df_se$charges, 
     main="Distribución de Charges", 
     xlab="Costos médicos", breaks=30)

hist(df_se$bmi, 
     main="Distribución de BMI", 
     xlab="IMC", breaks=20)

hist(df_se$age, 
     main="Distribución de Age", 
     xlab="Edad", breaks=15)

# Histograma de costos médicos con media y mediana
media_costos <- mean(df_se$charges)
mediana_costos <- median(df_se$charges)

ggplot(df_se, aes(x = charges)) +
  geom_histogram(bins = 30, fill = "lightblue", color = "black") +
  geom_vline(xintercept = media_costos, color = "red",size = 1) +
  geom_vline(xintercept = mediana_costos, color = "darkgreen", linetype = "dashed",size = 1) +
  
  labs(title = "Distribución de costos médicos",
       subtitle = paste("Mediana (Verde) = $", round(mediana_costos, 2), " | Media (Rojo) = $", round(media_costos, 2)),
       x = "Costos médicos",
       y = "Frecuencia"
       ) +
  
  theme_minimal()

########################## FIN ANÁLISIS UNIVARIADO ################################ 

########################## MATRIZ DE CORRELACIÓN LINEAL ################################

# Convertir variables categóricas a numéricas
df_se$sex_num    <- ifelse(df_se$sex == "male", 1, 0)    # hombre = 1, mujer = 0
df_se$smoker_num <- ifelse(df_se$smoker == "yes", 1, 0)  # fumador = 1, no fumador = 0

# Seleccionar las variables a evaluar (se excluye region por ser constante en df_se)
vars_corr <- df_se[, c("age", "bmi", "children", "sex_num", "smoker_num", "charges")]

# Matriz de correlación de Pearson
matriz_cor <- cor(vars_corr)
round(matriz_cor, 2)

# Visualización de matriz de correlación
corrplot(matriz_cor,
         method = "color",
         type = "upper",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         number.cex = 0.8,
         title = "Matriz de correlación - Southeast",
         mar = c(0,0,2,0))

# Modelo de regresión simple: charges ~ smoker
charges_smoker <- lm(charges ~ smoker, data = df_se)
summary(charges_smoker)
summary(charges_smoker)$r.squared  # 0.69 (ser fumador explica el 69% de la variación en charges)

########################## FIN MATRIZ DE CORRELACIÓN LINEAL ################################

########################## ANÁLISIS CHARGES & SMOKER ################################

# Cuántos de los outliers de charges son fumadores
outliers_charges_smoker <- sum(outliers$smoker == "yes")
print(outliers_charges_smoker) # 26
round(outliers_charges_smoker / nrow(outliers) * 100, 2) # 100%

# Calculo del límite superior
fumadores <- df_se[df_se$smoker == "yes", ]
q1_fumadores <- quantile(fumadores$charges, 0.25)
q3_fumadores <- quantile(fumadores$charges, 0.75)

lim_sup_fumadores <- q3_fumadores +
  1.5 * IQR(fumadores$charges)
print(lim_sup_fumadores)

summary(fumadores$charges)

# Boxplot de costos médicos según hábito de fumar
boxplot(charges ~ smoker,
        data = df_se,
        main = "Costos médicos según condición de fumador",
        xlab = "Smoker",
        ylab = "Charges")

########################## FIN ANÁLISIS CHARGES & SMOKER ################################

########################## ANÁLISIS CHARGES & BMI ################################

# Scatterplot: bmi vs charges
ggplot(df_se, aes(x = bmi, y = charges)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "#8D6374") +
  labs(title = "Relación entre IMC y costos médicos",
       x = "IMC", y = "Costos médicos") +
  theme_minimal()

# Modelo de regresión simple: charges ~ bmi
modelo_bmi <- lm(charges ~ bmi, data = df_se)
summary(modelo_bmi)$r.squared  # 0.02 (el bmi solo, no justifica los cambios en charges)

########################## FIN ANÁLISIS CHARGES & BMI ################################

########################## ANÁLISIS CHARGES & SEX ################################

# Boxplot de charges según sexo
boxplot(charges ~ sex,
        data = df_se,
        main = "Costos médicos según sexo",
        xlab = "Sexo",
        ylab = "Charges")

# Medias por grupo
aggregate(charges ~ sex, data = df_se, FUN = mean)
# female: 13,499.67 | male: 15,879.62

########################## FIN ANÁLISIS CHARGES & SEX ################################

########################## ANÁLISIS CHARGES & CHILDREN ################################

# Recategorizar children: agrupar 3, 4 y 5 en "3+"
df_se$children_grupo <- ifelse(df_se$children >= 3, "3+", as.character(df_se$children))
df_se$children_grupo <- factor(df_se$children_grupo, levels = c("0", "1", "2", "3+"))

# Frecuencia de cada grupo
table(df_se$children_grupo)

# Boxplot charges según children agrupado
boxplot(charges ~ children_grupo,
        data = df_se,
        main = "Costos médicos según cantidad de hijos",
        xlab = "Cantidad de hijos",
        ylab = "Charges")

# Medias del costo médico por grupo
aggregate(charges ~ children_grupo, data = df_se, FUN = mean)
# 0: 14,309.87
# 1: 13,687.04
# 2: 15,728.47
# 3+: 16,928.10

########################## FIN ANÁLISIS CHARGES & CHILDREN ################################

########################## ANÁLISIS CHARGES, SMOKER & BMI ################################

# Cuántos de los outliers de charges tienen BMI > 30 (obesidad)
outliers_charges_bmi <- sum(outliers$bmi > 30)
print(outliers_charges_bmi)  # 26
round(outliers_charges_bmi / nrow(outliers) * 100, 2) # 100%

# Modelo de regresión lineal de los costos según la relación entre IMC y tabaquismo
modelo_charges_bmi_smoker <- lm(charges ~ bmi * smoker, data = df_se)
summary(modelo_charges_bmi_smoker)  # r2 0.7958 # explica en un 79.58% la variación de charges
# charges = (9147.59 (intercept) - 16789.77(smokeryes)) + (-33.35 (bmi) + 1317.08 (bmi:smokeryes)) × bmi
# charges = -7642.18 + 1283.73 × bmi
# cada unidad extra de BMI aumenta el costo en aprox. $1,284

# Scatterplot bmi & charges según tabaquismo
ggplot(df_se, aes(x = bmi, y = charges, color = smoker)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Relación entre IMC y los costos médicos según condición de fumador",
       x = "IMC", y = "Costos médicos") +
  theme_minimal()

########################## FIN ANÁLISIS CHARGES, SMOKER & BMI ################################

########################## ANÁLISIS CHARGES, SMOKER & AGE ################################

# Edad promedio de los outliers de charges
mean(outliers$age) # 51.19

# Scatterplot age & charges según condición de fumador
ggplot(df_se, aes(x = age, y = charges, color = smoker)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(title = "Relación entre la edad y costos médicos según condición de fumador",
       x = "Edad", y = "Costos médicos") +
  theme_minimal()

########################## FIN ANÁLISIS CHARGES, SMOKER & AGE ################################

########################## ANÁLISIS CHARGES, SMOKER, BMI & AGE ################################

# Modelo de regresión para evaluar si la edad agregar costos adicionales a la relación bmi & smoker
modelo_charges_bmi_smoker_age <- lm(charges ~ bmi * smoker + age, data = df_se)
summary(modelo_charges_bmi_smoker_age) # r2: 0.8825

########################## FIN ANÁLISIS CHARGES, SMOKER, BMI & AGE ################################

########################## ANÁLISIS OUTLIERS NO FUMADORES ################################

# Outliers dentro del grupo no fumador 
no_fumadores <- df_se[df_se$smoker == "no", ]
summary(no_fumadores$charges)

q1_no_fumadores      <- quantile(no_fumadores$charges, 0.25)
q3_no_fumadores      <- quantile(no_fumadores$charges, 0.75)
lim_sup_no_fumadores <- q3_no_fumadores + 1.5 * IQR(no_fumadores$charges)

outliers_no_fumadores <- no_fumadores[no_fumadores$charges > lim_sup_no_fumadores, ]
nrow(outliers_no_fumadores) # 12

# Outliers no fumadores con BMI > 30
sum(outliers_no_fumadores$bmi > 30)  # 8
round(sum(outliers_no_fumadores$bmi > 30) / nrow(outliers_no_fumadores) * 100, 2)  # 66.67%

# Outliers no fumadores con más de 1 hijo
sum(outliers_no_fumadores$children > 1)  # 4
round(sum(outliers_no_fumadores$children > 1) / nrow(outliers_no_fumadores) * 100, 2) # 33.33%

# Comparar R
m_con_interaccion <- lm(charges ~ bmi * smoker + age * smoker, data = df_se)
summary(m_con_interaccion)

# Comparar R²
summary(m_final)$r.squared
summary(m_con_interaccion)$r.squared

########################## FIN ANÁLISIS OUTLIERS NO FUMADORES ################################

########################## COMPARACIÓN DE REGIONES ################################

# Función que encapsula el análisis "outliers + fumador + obesidad" para una región
analizar_region <- function(region_nombre, df_copy){
  
  df_region <- subset(df_copy, region == region_nombre)
  
  # Calcular límite superior de outliers para charges
  q1 <- quantile(df_region$charges, 0.25)
  q3 <- quantile(df_region$charges, 0.75)
  lim_sup <- q3 + 1.5 * IQR(df_region$charges)
  
  outliers <- df_region[df_region$charges > lim_sup, ]
  
  cant_outliers <- nrow(outliers)
  smokers <- round(sum(outliers$smoker == "yes") / cant_outliers * 100, 2)
  bmi30   <- round(sum(outliers$bmi > 30) / cant_outliers * 100, 2)
  smokers_bmi30   <- round(sum(outliers$smoker == "yes" & outliers$bmi > 30) / cant_outliers * 100, 2)
  
  data.frame(
    Region = region_nombre,
    cant_outliers = cant_outliers,
    porcentaje_total = round(cant_outliers / nrow(df_region) * 100, 2),
    porcentaje_fumadores = smokers,
    porcentaje_BMI_mayor_30 = bmi30,
    porcentaje_fumador_obeso = smokers_bmi30
  )
}

# Unir resultados de las 4 regiones
regiones <- unique(df_copy$region)
resultado_comparativo <- do.call(rbind, lapply(regiones, analizar_region, df_copy = df_copy))
resultado_comparativo

# Grafíco
ggplot(resultado_comparativo,
       aes(x = reorder(Region, porcentaje_fumador_obeso),
           y = porcentaje_fumador_obeso)) +
  
  geom_col(fill = "#7696AD") +
  
  geom_text(
    aes(label = paste0(porcentaje_fumador_obeso, "%")),
    vjust = -0.4,
    size = 4
  ) +
  
  labs(
    title = "Los outliers presentan perfiles similares en todas las regiones",
    subtitle = "Porcentaje de outliers que son simultáneamente fumadores y obesos",
    x = "Región",
    y = "Porcentaje (%)"
  ) +
  
  ylim(0, 110) +
  
  theme_minimal(base_size = 14)
########################## FIN COMPARACIÓN DE REGIONES ################################

########################## COMPARACIÓN R² DE LOS MODELOS ################################

# Extraer R² directamente de cada modelo analizado anteriormente
r2_bmi      <- summary(modelo_bmi)$r.squared
r2_smoker   <- summary(charges_smoker)$r.squared
r2_bmi_smoker  <- summary(modelo_charges_bmi_smoker)$r.squared
r2_bmi_smoker_age <- summary(modelo_charges_bmi_smoker_age)$r.squared

# Armar la tabla de comparación
comparacion_r2 <- data.frame(
  Modelo = c("bmi", "smoker", "bmi * smoker", "bmi * smoker + age"),
  R2 = round(c(r2_bmi, r2_smoker, r2_bmi_smoker, r2_bmi_smoker_age), 4)
)

 print(comparacion_r2)

ggplot(comparacion_r2, aes(x = reorder(Modelo, R2), y = R2)) +  # reorder ordena de menor a mayor. De mayor a menor sería aes(x = reorder(Modelo, -R2), y = R2)
  geom_col(fill = "#7696AD") +
  geom_text(aes(label = paste0(round(R2 * 100, 2), "%")),
            vjust = -0.5, size = 3.5) +
  ylim(0, 1) +
  labs(
    title = "Comparación de R² entre modelos",
    x = "Modelo",
    y = "R²"
  ) +
  theme_minimal()

########################## FIN COMPARACIÓN R² DE LOS MODELOS ################################



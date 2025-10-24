## 🗂 Estructura de carpetas

DATA-ENGINEERING-PROYECTO1/
├─ .venv/ # Entorno virtual de Python
├─ AVANCE1/ # Primer avance: carga inicial y exploración
│ ├─ ImagenesA1/
│ ├─ analisis_avance1.ipynb
│ └─ CodigoA1.sql
├─ AVANCE2/ # Segundo avance: limpieza y validaciones SQL
│ ├─ ImagenesA2/
│ ├─ analisis_avance2.ipynb
│ └─ CodigoA2.sql
├─ AVANCE3/ # Tercer avance: integración y dataset final
│ ├─ analisis_avance3.ipynb
│ └─ Cargar_data.py
├─ DATA/ # Archivos CSV base de cada tabla
│ ├─ sales.csv
│ ├─ products.csv
│ ├─ employees.csv
│ ├─ customers.csv
│ ├─ cities.csv
│ ├─ countries.csv
│ └─ categories.csv
├─ README.md # Este documento
└─ requirements.txt # Librerías utilizadas


---

##  Flujo general del proyecto

1. **Carga de datos (Extract)**
   - Se cargan los 7 archivos `.csv` desde la carpeta `DATA/`.
   - Se manejan los archivos grandes (como `sales.csv`) mediante **lectura por chunks** para evitar errores de memoria.
   - Se validan tipos de datos (numéricos y fechas) y columnas nulas.

2. **Transformación (Transform)**
   - Se limpian los valores inconsistentes y se convierten los tipos de datos:
     - `BirthDate`, `HireDate`, `SalesDate` → tipo fecha.
     - `Price`, `Quantity`, `Discount` → tipo numérico.
   - Se crean nuevas **features**:
     - `EdadAlContratar`: edad del empleado al momento de contratación.
     - `AniosExperiencia`: años de experiencia al momento de cada venta.
     - `TotalPriceCalculated`: columna calculada (`Quantity * Price * (1 - Discount)`).

3. **Integración (Join / Merge)**
   - Se unen las tablas: `sales`, `products`, `employees`, `customers`, `cities`, `countries` y `categories`.
   - Resultado: un único **DataFrame final** con toda la información consolidada.

4. **Preparación para modelado**
   - Se aplican transformaciones:
     - **Target Encoding** para variables categóricas de alta cardinalidad (`CountryName`, `CityName`, `CategoryName`).
     - **One-Hot Encoding** para variables con pocas categorías (`Class`, `Resistant`, `IsAllergic`).
   - Las variables numéricas se mantienen sin escalar, excepto las de fechas que se descomponen en año, mes, día, hora y día de la semana.
   - Variable objetivo (`TotalPriceCalculated`) se conserva sin transformar.

5. **Exportación**
   - El dataset final se guarda como:
     ```
     C:\Users\Mi Pc\Documents\IntegradorProject\dataset_final_modelo.csv
     ```
   - Este archivo contiene el conjunto limpio y listo para usar en modelos de Machine Learning.

---

##  Tecnologías y herramientas utilizadas

| Tipo | Herramienta |
|------|--------------|
| **Lenguaje** | Python 3.13.1 |
| **Entorno** | VSCode + Jupyter Notebooks |
| **Base de datos** | MySQL |
| **Cliente SQL** | DBeaver |
| **Librerías principales** | pandas, numpy, pathlib, sklearn |
| **Control de versiones** | Git + GitHub |
| **Formato de datos** | CSV |

---

##  Resultados principales

- Dataset final consolidado con más de **6 millones de registros**.
- Optimización de memoria mediante lectura por **chunks**.
- Cálculo correcto de indicadores temporales y laborales.
- Codificación eficiente de variables categóricas sin pérdida de información.

---

##  Consideraciones y buenas prácticas

- Se recomienda ejecutar los notebooks con entorno virtual activado (`.venv`).
- Evitar cargar todo el CSV de `sales` en memoria; usar `chunksize`.
- Las rutas fueron parametrizadas para mantener compatibilidad en distintos entornos.

---

##  Próximos pasos

- Análisis de correlaciones entre variables.
- Creación de un modelo de predicción de precios totales (`TotalPriceCalculated`).
- Exportación a un formato más eficiente (`Parquet`).

---

##  Autor

**Nombre:** Hanks Reyes




import pandas as pd
import numpy as np

# asegurar que tienes estos DFs cargados: sales, products, employees, customers, cities, categories, countries
# convertir a datetime y numéricos
sales['SalesDate'] = pd.to_datetime(sales['SalesDate'], errors='coerce')
employees['BirthDate'] = pd.to_datetime(employees['BirthDate'], errors='coerce')
employees['HireDate']  = pd.to_datetime(employees['HireDate'], errors='coerce')
products['Price'] = pd.to_numeric(products['Price'], errors='coerce')

# Unificar nombre de columna de vendedor si hace falta
if 'SalesPersonID' in sales.columns and 'EmployeeID' not in sales.columns:
    sales = sales.rename(columns={'SalesPersonID':'EmployeeID'})

# asegurar columnas numéricas básicas
sales['Quantity'] = pd.to_numeric(sales['Quantity'], errors='coerce').fillna(0)
sales['Discount'] = pd.to_numeric(sales['Discount'], errors='coerce').fillna(0)

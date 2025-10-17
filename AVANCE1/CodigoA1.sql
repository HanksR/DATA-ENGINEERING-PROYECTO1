
-- Explorar los datos mediante consultas SQL y responder las preguntas planteadas sobre calidad
--  y transformación de los datos:

-- Question 1 : (Inciso A)   16 seg
-- ¿Cuáles fueron los 5 productos más vendidos (por cantidad total)?      

SELECT 
    p.ProductID,
    p.ProductName,
    SUM(s.Quantity) AS TotalUnitsSold
FROM sales s
JOIN products p ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalUnitsSold DESC
LIMIT 5;


-- Question 2 : (Inciso B) 23 seg
-- ¿Cuál fue el vendedor que más unidades vendió de cada uno?             
-- Al inicio lo hize con WHERE y demoro 16 minutos , tuve que adaptarlo 
-- con funciones ventana y sin usar el WHERE (estas subconsultas) 
-- y recien pude optimizarlo

WITH ranking_vendedores AS (
    SELECT
        s.ProductID,
        p.ProductName,
        s.SalesPersonID AS EmployeeID,
        e.FirstName,
        e.LastName,
        SUM(s.Quantity) AS UnidadesVendidas,
        SUM(SUM(s.Quantity)) OVER (PARTITION BY s.ProductID) AS TotalPorProducto,
        RANK() OVER (PARTITION BY s.ProductID ORDER BY SUM(s.Quantity) DESC) AS Posicion
    FROM sales s
    INNER JOIN products p ON s.ProductID = p.ProductID
    INNER JOIN employees e ON s.SalesPersonID = e.EmployeeID
    GROUP BY s.ProductID, p.ProductName, s.SalesPersonID, e.FirstName, e.LastName
)
SELECT
    ProductID,
    ProductName,
    EmployeeID,
    FirstName,
    LastName,
    UnidadesVendidas,
    TotalPorProducto,
    ROUND(UnidadesVendidas * 100.0 / TotalPorProducto, 2) AS PorcentajeContribucion
FROM ranking_vendedores
WHERE Posicion = 1
ORDER BY TotalPorProducto DESC
LIMIT 5;


-- Question 3 : (Inciso C) 27 seg
-- Entre los 5 productos más vendidos 
-- ¿Cuántos clientes únicos compraron cada uno y qué proporción representa sobre el total de clientes?   

WITH Top5Productos AS (
    SELECT 
        s.ProductID,
        p.ProductName,
        SUM(s.Quantity) AS UnidadesVendidas
    FROM sales s
    INNER JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName
    ORDER BY UnidadesVendidas DESC
    LIMIT 5
)
SELECT
    t5.ProductID,
    t5.ProductName,
    COUNT(DISTINCT s.CustomerID) AS ClientesUnicos,
    (SELECT COUNT(DISTINCT CustomerID) FROM sales) AS TotalClientes,
    ROUND(COUNT(DISTINCT s.CustomerID) * 100.0 / 
          (SELECT COUNT(DISTINCT CustomerID) FROM sales), 2) AS PorcentajeClientes
FROM Top5Productos t5
INNER JOIN sales s ON t5.ProductID = s.ProductID
GROUP BY t5.ProductID, t5.ProductName
ORDER BY t5.UnidadesVendidas DESC;


-- Question 4 : (Inciso D) 16 seg
-- ¿A qué categorías pertenecen los 5 productos más vendidos y
-- qué proporción representan dentro del total de unidades vendidas de su categoría? 

WITH VentasPorProducto AS (
    SELECT
        s.ProductID,
        p.ProductName,
        p.CategoryID,
        SUM(s.Quantity) AS UnidadesVendidas
    FROM sales s
    INNER JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName, p.CategoryID
),
VentasConTotalCategoria AS (
    SELECT
        vp.ProductID,
        vp.ProductName,
        vp.CategoryID,
        vp.UnidadesVendidas,
        SUM(vp.UnidadesVendidas) OVER (PARTITION BY vp.CategoryID) AS TotalEnCategoria
    FROM VentasPorProducto vp
),
Top5 AS (
    SELECT
        ProductID
    FROM VentasPorProducto
    ORDER BY UnidadesVendidas DESC
    LIMIT 5
)
SELECT
    v.ProductName AS NombreProducto,
    c.CategoryName AS Categoria,
    v.UnidadesVendidas,
    v.TotalEnCategoria,
    ROUND( v.UnidadesVendidas * 100.0 / v.TotalEnCategoria, 2 ) AS PorcentajeDentroCategoria
FROM VentasConTotalCategoria v
JOIN Top5 t ON v.ProductID = t.ProductID
JOIN categories c ON v.CategoryID = c.CategoryID
ORDER BY v.UnidadesVendidas DESC;



-- Question 5 : (Inciso E) 16 seg
-- ¿Cuáles son los 10 productos con mayor cantidad de unidades vendidas 
--  en todo el catálogo y cuál es su posición dentro de su propia categoría? 

WITH VentasPorProducto AS (
    SELECT
        s.ProductID,
        p.ProductName,
        p.CategoryID,
        SUM(s.Quantity) AS UnidadesVendidas
    FROM sales s
    INNER JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName, p.CategoryID
),
RankingProductos AS (
    SELECT
        vp.ProductID,
        vp.ProductName,
        vp.CategoryID,
        vp.UnidadesVendidas,
        RANK() OVER (ORDER BY vp.UnidadesVendidas DESC) AS PosicionGlobal,
        RANK() OVER (PARTITION BY vp.CategoryID ORDER BY vp.UnidadesVendidas DESC) AS PosicionEnCategoria
    FROM VentasPorProducto vp
    ORDER BY vp.UnidadesVendidas DESC
    LIMIT 10
)
SELECT
    r.ProductName AS NombreProducto,
    c.CategoryName AS Categoria,
    r.UnidadesVendidas,
    r.PosicionGlobal AS RankingGlobal,
    r.PosicionEnCategoria AS RankingCategoria
FROM RankingProductos r
INNER JOIN categories c ON r.CategoryID = c.CategoryID
ORDER BY r.UnidadesVendidas DESC;





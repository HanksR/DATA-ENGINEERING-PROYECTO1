-- Selecciona dos consultas del avance 1 y crea los índices que consideres
-- más adecuados para optimizar su ejecución.  


-- Question 2 del Avance 1 :  23 seg -> 5.9 seg
WITH ventas_agrupadas AS (
    SELECT
        s.ProductID,
        s.SalesPersonID,
        SUM(s.Quantity) AS UnidadesVendidas
    FROM sales s
    GROUP BY s.ProductID, s.SalesPersonID
),
ranking_vendedores AS (
    SELECT
        va.ProductID,
        va.SalesPersonID,
        va.UnidadesVendidas,
        SUM(va.UnidadesVendidas) OVER (PARTITION BY va.ProductID) AS TotalPorProducto,
        RANK() OVER (PARTITION BY va.ProductID ORDER BY va.UnidadesVendidas DESC) AS Posicion
    FROM ventas_agrupadas va
)
SELECT
    rv.ProductID,
    p.ProductName,
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    rv.UnidadesVendidas,
    rv.TotalPorProducto,
    ROUND(rv.UnidadesVendidas * 100.0 / rv.TotalPorProducto, 2) AS PorcentajeContribucion
FROM ranking_vendedores rv
JOIN products p ON rv.ProductID = p.ProductID
JOIN employees e ON rv.SalesPersonID = e.EmployeeID
WHERE rv.Posicion = 1
ORDER BY rv.TotalPorProducto DESC
LIMIT 5;

-- Indices creados demoro 9.5 seg 
-- (Inciso A)  5.9 seg   ->  5.4 seg

CREATE INDEX idx_sales_product
ON sales (SalesPersonID, Quantity);  

-- Indice creados demoro  8.3 seg 
-- (Inciso A)  5.9 seg   ->  5.5 seg
CREATE INDEX idx_sales_product
ON sales (SalesPersonID);

-- Indice creados demoro  8.3 seg 
-- (Inciso A)  5.9 seg   ->  5.3 seg
CREATE INDEX idx_sales_product
ON sales (Quantity);


-- Indices creados demoraron 11 seg 
-- (Inciso A)  5.9 seg   ->  1.7 seg
CREATE INDEX idx_sales_product_salesperson_qty
ON sales (ProductID, SalesPersonID, Quantity);




-- Question 3 del Avance 1 :  27 seg -> 18 seg

WITH VentasPorProducto AS (
    SELECT 
        s.ProductID,
          SUM(s.Quantity) AS UnidadesVendidas
    FROM sales s
    GROUP BY s.ProductID
),
Top5 AS (
    SELECT 
         vp.ProductID,
        p.ProductName,
          vp.UnidadesVendidas
    FROM VentasPorProducto vp
    INNER JOIN products p ON vp.ProductID = p.ProductID
    ORDER BY vp.UnidadesVendidas DESC
    LIMIT 5
),
TotalClientes AS (
    SELECT COUNT(DISTINCT CustomerID) AS TotalClientes FROM sales
)
SELECT
    t.ProductID,
    t.ProductName,
    COUNT(DISTINCT s.CustomerID) AS ClientesUnicos,
    tc.TotalClientes,
    ROUND(COUNT(DISTINCT s.CustomerID) * 100.0 / tc.TotalClientes, 2) AS PorcentajeClientes
FROM sales s
INNER JOIN Top5 t ON s.ProductID = t.ProductID
CROSS JOIN TotalClientes tc
GROUP BY t.ProductID, t.ProductName, tc.TotalClientes
ORDER BY t.UnidadesVendidas DESC;



-- Indices creados demoraron 10 seg 
-- (Inciso A)  18 seg   ->  3.4 seg
CREATE INDEX idx_sales_product_customer_qty
ON sales (ProductID, CustomerID, Quantity);



-- TRIGGERS 
-- Crea un trigger que registre en una tabla
-- de monitoreo cada vez que un producto supere las 200.000 unidades vendidas acumuladas.

-- Observamos las cantidades actuales de productos  (ninguno supera los 200k aun)
select p.productID, p.ProductName, SUM(Quantity) from sales s
inner join products p on s.productID = p.productID
where p.ProductID between 99 and 105
group by productID 


-- Creamos nuestra Tabla de monitoreo, almacenamos las acciones
CREATE TABLE tabla_monitoreo (
    MonitorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    ProductName VARCHAR(150),
    UnidadesVendidas BIGINT,
    FechaRegistro DATETIME,
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);


-- Creamos un trigger que se active al superar las 200k ventas por producto
CREATE TRIGGER trg200k
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    DECLARE total BIGINT;

    SELECT SUM(s.Quantity)
    INTO total
    FROM sales s
    WHERE s.ProductID = NEW.ProductID;

    IF total > 200000 THEN
        INSERT INTO tabla_monitoreo 
        (ProductID, ProductName, UnidadesVendidas, FechaRegistro)
        SELECT 
            p.ProductID,
            p.ProductName,
            total,
            NOW()
        FROM products p
        WHERE p.ProductID = NEW.ProductID;
    END IF;
end;

-- Insertamos valores en el ProductID = 103 , para probar nuestro Trigger

INSERT INTO sales (
    SalesPersonID,
    CustomerID,
    ProductID,
    Quantity,
    Discount,
    TotalPrice,
    SalesDate,
    TransactionNumber
)
VALUES (9, 84, 103, 1876, 0, 1200, NOW(), 'PRUEBA-103');


SELECT * FROM tabla_monitoreo;


































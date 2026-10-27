-- =====================================================
-- Pre-entrega M5: Cruzando tablas para enriquecer el análisis
-- =====================================================

--Ponemos en uso nuestra Base de Datos
USE VentasTechDB;

-- -----------------------------------------------------
-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Cada venta con nombre del cliente, ciudad, producto,
-- categoría, cantidad, precio unitario y total.
-- Columna para agrupar: categoria / ciudad
-- Columna para filtrar: fecha / ciudad
-- -----------------------------------------------------
SELECT
      FechaVenta AS Fecha,
      v.ClienteID AS Cliente,
      p.NombreProducto AS Producto,
      cat.CategoriaID AS Categoria,
      Cantidad,
      PrecioUnitario,
      Cantidad * PrecioUnitario AS TotalVenta
FROM dbo.Ventas v
INNER JOIN Clientes c 
   ON V.ClienteID = C.Ciudad
INNER JOIN Productos p 
   ON v.ProductID = p.ProductID
INNER JOIN Categoria cat
   ON p.CategoriaID = cat.CategoriaID;


-- -----------------------------------------------------
-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que nunca realizaron una compra.
-- -----------------------------------------------------
SELECT
      c.Nombre,
      c.FechaRegistro,
      c.Email
FROM dbo.Clientes c
LEFT JOIN  Ventas V
   ON c.ClienteID = v.ClienteID
WHERE v.VentaID IS NULL;


-- -----------------------------------------------------
-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Productos del catálogo sin ninguna venta registrada.
-- -----------------------------------------------------
SELECT
      p.NombreProducto,
      p.Precio,
      p.CategoriaID
FROM dbo.Productos p
LEFT JOIN Ventas AS v
    ON p.ProductID = v.ProductID
    WHERE v.VentaID IS NULL;

-- -----------------------------------------------------
-- Consulta 4 — Consolidado por canal (UNION ALL)
-- La columna "canal" no existe en las tablas: se crea como valor literal en cada SELECT. Criterio: dos sucursales (Buenos Aires e Interior), según la ciudad del cliente.
-- Se usa UNION ALL para que cada venta se cuente una vez aunque coincida con otra en todos sus valores.
-- -----------------------------------------------------
SELECT
    Canal,
    COUNT(*) AS CantidadVentas,
    SUM(Total) AS TotalFacturado
FROM (
    SELECT
        v.FechaVenta AS Fecha,
        v.Cantidad * v.PrecioUnitario AS Total,
        'Sucursal Buenos Aires' AS Canal
    FROM dbo.Ventas v
    INNER JOIN dbo.Clientes c
        ON v.ClienteID = c.ClienteID
    WHERE c.Ciudad = 'Buenos Aires'

    UNION ALL

    SELECT
        v.FechaVenta AS Fecha,
        v.Cantidad * v.PrecioUnitario AS Total,
        'Sucursal Interior' AS Canal
    FROM dbo.Ventas v
    INNER JOIN dbo.Clientes c
        ON v.ClienteID = c.ClienteID
    WHERE c.Ciudad <> 'Buenos Aires'
) AS VentasporCanal
GROUP BY Canal;